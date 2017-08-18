import {getUserFiltered} from '../get'

describe('Get User', () => {
  it('- should find a user', async () => {
    const fixture = {
      id: '1',
      name: 'Bob Pogo',
      username: 'bobpogo'
    }
    const user = await getUserFiltered(fixture.id)
    expect(user).toHaveProperty('name', fixture.name)
    expect(user).toHaveProperty('username', fixture.username)
  })
})
