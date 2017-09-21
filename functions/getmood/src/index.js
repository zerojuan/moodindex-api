import React from 'Lib/mood/react'

export default function (e, context) {
  console.log('ReactMood Event', e)

  return ReactMood(e)
    .then((result) => {
      return context.succeed(result)
    })
    .catch((err) => {
      console.log( JSON.stringify( err ) );
      return context.fail(JSON.stringify(err))
    })
}
