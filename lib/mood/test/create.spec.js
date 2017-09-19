import errors from 'restify-errors'

import MoodCreate from '../create'

describe('MoodCreate', () => {
  let fixture
  beforeEach(() => {
    fixture = {
      principalId: '1',
      mood: {
        value: 0
      }
    }
  })
  it('- Should 404 on invalid principalId', async () => {
    fixture.principalId = '99'

    await expect(MoodCreate(fixture)).rejects.toMatchObject(new errors.NotFoundError(
      'NotFoundError: user not found'
    ))
  })
  it('- Should 400 on value being too high', async () => {
    fixture.mood.value = 99

    await expect(MoodCreate(fixture)).rejects.toMatchObject(new errors.BadRequestError(
       'BadRequestError: mood out of range'
    ))
  })
  it('- Should 400 on value being too low', async () => {
    fixture.mood.value = -99
    await expect(MoodCreate(fixture)).rejects.toMatchObject(new errors.BadRequestError(
      'BadRequestError: mood out of range'
    ))
  })
  it('- Should return with the created Mood', async () => {
    const result = await MoodCreate(fixture)

    expect(result).toHaveProperty('value', fixture.mood.value)
    expect(result).toHaveProperty('created')
    expect(result).toHaveProperty('owner.id', fixture.principalId)
  })
})
