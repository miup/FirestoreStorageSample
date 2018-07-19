import * as gcs from '@google-cloud/storage'
import * as os from 'os'
import * as fs from 'fs'
import * as path from 'path'
import { spawn } from 'process-promises'
import * as Tart from '@star__hoshi/tart'

export interface Image extends Tart.Timestamps {
  fileName: string
  originalRefPath: string
}

enum ResizeType {
  Large = 'large',
  Medium = 'medium',
  Small = 'small',
  Thumbnail = 'thumbnail'
}

function resizeInfo(resizeType: ResizeType): string {
  switch (resizeType) {
    case ResizeType.Large: return '1242x1242>'
    case ResizeType.Medium: return '495x495>'
    case ResizeType.Small: return '252x252>'
    case ResizeType.Thumbnail: return '144x144>'
    default: return ''
  }
}

function fieldValueName(resizeType: ResizeType): string {
  switch (resizeType) {
    case ResizeType.Large: return 'largeRefPath'
    case ResizeType.Medium: return 'mediumRefPath'
    case ResizeType.Small: return 'smallRefPath'
    case ResizeType.Thumbnail: return 'thumbnailRefPath'
    default: return ''
  }
}

export async function resize(image: Tart.Snapshot<Image>) {
  const imageID = image.ref.id
  const fileName = image.data.fileName
  const filePath = `images/${imageID}/${fileName}`
  // instantiate Google Storage Bucket
  const bucket = gcs().bucket(JSON.parse(process.env.FIREBASE_CONFIG).storageBucket)
  const file = await bucket.file(filePath).get().then(result => { return result[0] })
  // /tmp/${fileName}
  const tempFilePath = path.join(os.tmpdir(), fileName)
  await file.download({ destination: tempFilePath })

  const resizeTypes: ResizeType[] = [
    ResizeType.Large,
    ResizeType.Medium,
    ResizeType.Small,
    ResizeType.Thumbnail]
  await Promise.all(resizeTypes.map(type => {
    return resizeImage(tempFilePath, fileName, type)
      .then(source => uploadToBucket(bucket, source, type, fileName, filePath))
      .then(() => updateImageModel(image, type))
  }))

}

function resizeImage(filePath: string, fileName: string, resizeType: ResizeType) {
  const dest = path.join(os.tmpdir(), `${resizeType}_${fileName}`)
  return spawn('convert', [filePath, '-thumbnail', resizeInfo(resizeType), `${dest}`])
    .then(() => { return dest })
}

function uploadToBucket(bucket: gcs.Bucket, source: string, prefix: string, fileName: string, filePath: string) {
  const destName = `${prefix}_${fileName}`
  const destDir = path.dirname(filePath)
  const dest = path.join(destDir, destName)
  return bucket
    .upload(source, {
      destination: dest
    })
    // delete tmp/${ResizeType.prefix}_${fileName}
    .then(() => fs.unlinkSync(source))
}

function updateImageModel(image: Tart.Snapshot<Image>, resizeType: ResizeType) {
  const key = fieldValueName(resizeType)
  const updateInfo: { [id: string]: string } = {}
  const refPath = `images/${image.ref.id}/${resizeType}_${image.data.fileName}`
  updateInfo[key] = refPath
  return image.update(updateInfo)
}
