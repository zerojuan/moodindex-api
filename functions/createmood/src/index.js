import MoodCreate from 'Lib/mood/create'

export default function (e, context) {
  console.log('MoodIndex Event', e)

  return MoodCreate(e)
    .then((result) => {
      return context.succeed(result)
    })
    .catch((err) => {
      return context.fail(JSON.stringify(err))
    })
}
