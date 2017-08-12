import MoodIndex from 'Lib/mood'

export default function (e, context) {
  console.log('MoodIndex Event', e)

  return MoodIndex(e)
    .then((result) => {
      return context.succeed(result)
    })
    .catch((err) => {
      return context.fail(JSON.stringify(err))
    })
}
