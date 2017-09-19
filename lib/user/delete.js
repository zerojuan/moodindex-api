import errors from 'restify-errors'

import { getItem, putTo } from '../db'

export default async function ({ principalId, userToDeleteId }) {
  try {
    if (principalId === userToDeleteId) {
      throw new errors.ConflictError('ConflictError: cannot delete self')
    }

    // search user to delete
    const userToDelete = await getItem('Users', {
      id: userToDeleteId
    })

    if (!userToDelete || userToDelete.deleted) {
      throw new errors.NotFoundError('NotFoundError: user not found')
    }

    userToDelete.deleted = true
    await putTo('Users', userToDelete)

    // TODO: how to return a 204 easily? maybe use lambda proxies
    return 'Success'
  } catch (err) {
    return Promise.reject(err)
  }
}
