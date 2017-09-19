import errors from 'restify-errors'
import { getItem } from '../db'
import { getUserFiltered } from '../user/get'
import { getReactList } from './react'

export async function moodFull ({ ownerId, created }) {
  const mood = await getItem('Moods', {
    ownerId: ownerId,
    created: created
  })

  if (!mood) {
    throw new errors.NotFoundError('NotFoundError: mood not found')
  }

  // get owner object
  const user = await getUserFiltered(ownerId)
  mood.owner = user

  if (mood.reactRef) {
    mood.reacts = await getReactList(mood)
  }

  return mood
}

export default async function ({ ownerId, created }) {
  try {
    // get Item
    return await moodFull({
      ownerId, created })
  } catch (err) {
    return Promise.reject(err)
  }
}
