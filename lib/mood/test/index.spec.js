import MoodIndex from '../index'

describe('MoodIndex', () => {
  it('- Should return a paginated object', async () => {
    const result = await MoodIndex({ principalId: 1 })

    expect(result).toHaveProperty('results')
    expect(result).toHaveProperty('resultsMetadata')
    expect(result).toHaveProperty('resultsMetadata.lastItem')
    expect(result).toHaveProperty('resultsMetadata.total')
    expect(result).toHaveProperty('resultsMetadata.pageSize')
  })
  it('- Should return all moods in the world', async () => {
    const result = (await MoodIndex({ principalId: 1 }))

    expect(result.results.length).toBeGreaterThan(1)
    expect(result.results[ 0 ]).toHaveProperty('owner.name')
    expect(result.results[ 0 ]).toHaveProperty('value')
    expect(result.results[ 0 ]).toHaveProperty('created')
  })
  it('- Should paginate with specific size ', async () => {
    const result = await MoodIndex({ principalId: 1,
      queryParams: {
        pageSize: 1,
        currentIndex: { 'ownerId': '1', 'created': '2016-11-12T17:21:07.5272333Z' }
      } })

    expect(result.results).toHaveLength(1)
  })
})
