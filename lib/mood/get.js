import { getItem } from '../db'
import { getUserFiltered } from '../user/get'

export async function moodFull ({ ownerId, created }) {
  const mood = await getItem('Moods', {
    ownerId: ownerId,
    created: created
  })

  if (!mood) {
    throw new Error('NotFoundError: mood not found')
  }

  // get owner object
  const user = await getUserFiltered(ownerId)
  mood.owner = user

  // TODO: get a list of reacts
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
