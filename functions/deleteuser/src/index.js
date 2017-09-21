import DeleteUser from 'Lib/user/delete'

export default function (e, context) {
  console.log('DeleteUser Event', e)

  return DeleteUser(e)
    .then((result) => {
      return context.succeed(result)
    })
    .catch((err) => {
      console.log( JSON.stringify( err ) );
      return context.fail(JSON.stringify(err))
    })
}
