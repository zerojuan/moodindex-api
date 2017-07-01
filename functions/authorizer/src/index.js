import Auth from 'Lib/auth';

export default function( e, context ) {
  console.log( 'Auth Event', e );

  return Auth( e )
    .then( ( result ) => {
      return context.succeed( result );
    } )
    .catch( ( err ) => {
      return context.fail( err );
    } );
}
