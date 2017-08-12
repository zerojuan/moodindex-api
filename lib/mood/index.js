import { scan, softCount, batchGet } from '../db'

export default async function ({ principalId, queryParams }) {
  // search all moods
  const params = {}

  if (!queryParams) {
    params.Limit = 10
  } else {
    params.Limit = queryParams.pageSize
    if (queryParams.currentIndex.ownerId) {
      params.ExclusiveStartKey = queryParams.currentIndex
    }
  }

  const count = await softCount('Moods')
  const scanResult = await scan('Moods', params)

  // batchGet users
  const owners = await batchGet('Users',
    // Remove duplicates and flatten
    [ ...new Set(scanResult.Items.map((item) => item.ownerId)) ]
      .map((item) => { return { id: item } }),
    // Only return these attributes
    [ 'username', 'name', 'id' ])

  // inflate owner object to scanResult
  scanResult.Items = scanResult.Items.map((item) => {
    item.owner = owners.find((owner) => { return item.ownerId === owner.id })
    return item
  })

  const pagedMoods = {
    results: scanResult.Items,
    resultsMetadata: {
      lastItem: scanResult.LastEvaluatedKey,
      total: count,
      pageSize: params.Limit
    }
  }

  return pagedMoods
}
