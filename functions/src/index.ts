import * as functions from 'firebase-functions'
import * as Tart from '@star__hoshi/tart'
import { resize, Image} from './image'

export const resizeImage = functions.firestore.document('images/{imageID}').onCreate((snapshot, context) => {
  const image = new Tart.Snapshot<Image>(snapshot)
  return resize(image)
})
