import Login from 'Lib/auth/login';

export default function( e, context ) {
  console.log( 'Event', e );

  return Login( e )
    .then( ( result ) => {
      return context.succeed( result );
    } )
    .catch( ( err ) => {
      return context.fail( err );
    } );
}
