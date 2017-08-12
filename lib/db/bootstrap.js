
// NOTE: not using import/export because our bin script is using this
module.exports = (db) => {
  // TODO: make this more dynamic
  const dbData = [
    require('../../data/permissions.json'),
    require('../../data/users.json'),
    require('../../data/moods.json'),
    require('../../data/reacts.json')
  ]

  return Promise.all(
    dbData.map((data) => {
      return db.batchWrite({
        RequestItems: data
      }).promise()
    })
  )
}
