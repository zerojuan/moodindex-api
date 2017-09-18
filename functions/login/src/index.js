import Login from 'Lib/auth/login'

export default function (e, context) {
  console.log('Event', e)

  return Login(e.user)
    .then((result) => {
      return context.succeed(result)
    })
    .catch((err) => {
      console.log( JSON.stringify( err ) );
      return context.fail(JSON.stringify( err ))
    })
}
