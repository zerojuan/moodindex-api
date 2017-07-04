import Auth, { parseEnvironment } from 'Lib/auth';

export default function( e, context ) {
  console.log( 'Auth Event', e );

  // extract environment based on url
  process.env.ENVIRONMENT = parseEnvironment( e.methodArn );

  return Auth( e )
    .then( ( result ) => {
      return context.succeed( result );
    } )
    .catch( ( err ) => {
      return context.fail( err );
    } );
}
