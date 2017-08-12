import DeleteUser from '../delete'
import { db } from '../../db'
import dbBootstrap from '../../db/bootstrap'

describe('Delete User', () => {
  beforeAll(async () => {
    await dbBootstrap(db)
  })

  it('- Should delete a user', async () => {
    const fixture = {
      principalId: '1',
      userToDeleteId: '2'
    }

    await expect(DeleteUser(fixture)).resolves.toBe('Success')
  })

  it('- Should not delete yourself', async () => {
    const fixture = {
      principalId: '1',
      userToDeleteId: '1'
    }

    await expect(DeleteUser(fixture)).rejects.toMatchObject({
      message: 'ConflictError: cannot delete self'
    })
  })

  it('- Should NotFoundError on unknown user to delete', async () => {
    const fixture = {
      principalId: '1',
      userToDeleteId: '200'
    }

    await expect(DeleteUser(fixture)).rejects.toMatchObject({
      message: 'NotFoundError: user not found'
    })
  })

  // TODO: add more tests
})
