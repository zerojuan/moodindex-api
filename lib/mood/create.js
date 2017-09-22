import errors from 'restify-errors'
import { getItem, putTo } from '../db'
import { getUserFiltered } from '../user/get'

export default async function ({ principalId, mood }) {
  // check that the user exists?
  try {
    const owner = await getUserFiltered(principalId)
    if (!owner) {
      throw new errors.NotFoundError('NotFoundError: user not found')
    }

    // value is not defined
    if ( mood.value === undefined ) {
      throw new errors.BadRequestError('BadRequestError: mood value is not defined')
    }

    // check that the value is between -5 and 5
    if (mood.value > 5 || mood.value < -5) {
      throw new errors.BadRequestError('BadRequestError: mood out of range')
    }

    // insert into database
    const newMood = {
      ownerId: principalId,
      value: mood.value,
      created: (new Date()).toUTCString()
    }
    await putTo('Moods', newMood)

    const savedMood = await getItem('Moods', { ownerId: newMood.ownerId, created: newMood.created })
    savedMood.owner = owner

    return savedMood
  } catch (err) {
    return Promise.reject(err)
  }
}
