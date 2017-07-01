import Auth, { generatePolicy, decodeToken } from '../index';
import jwt from 'jsonwebtoken';

describe( 'Authenticator', () => {
  describe( 'Policy Generation', () => {
    it( '- should return correct policy', () => {
      const fixture = {
        userId: 'user-id-1010',
        permissions: [ {
          effect: "allow",
          route: "GET/*"
        } ],
        methodArn: 'arn:aws:execute-api:<regionId>:<accountId>:<apiId>/<stage>/<method>/<resourcePath>'
      };

      const policy = generatePolicy( fixture.userId, fixture.methodArn, fixture.permissions );

      expect( policy.principalId ).toEqual( fixture.userId );
      expect( policy.policyDocument.Statement[ 0 ].Action ).toEqual( 'execute-api:Invoke' );
      expect( policy.policyDocument.Statement[ 0 ].Effect ).toEqual( fixture.permissions[ 0 ].effect );
      expect( policy.policyDocument.Statement[ 0 ].Resource ).toEqual(
        `arn:aws:execute-api:<regionId>:<accountId>:<apiId>/<stage>/${fixture.permissions[ 0 ].route}`
      );
      expect( policy.context.message ).toEqual( 'Authenticate Success' );
    } );
  } );

  describe( 'Token Decoding', () => {
    it( '- should decode a token using a secret', () => {
      // load sample token
      const fixture = {
        userId: 'test-id',
        roles: [ 'user:*' ]
      };

      const decodedToken = decodeToken(
        jwt.sign( fixture, process.env.JWT_SECRET )
      );

      expect( decodedToken.userId ).toBe( fixture.userId );
      expect( decodedToken.type ).toBe( fixture.type );

    } );
  } );

  describe( 'Authentication', () => {
    it( '- should return a policy response', async () => {
      const tokenFixture = {
        sub: '1',
        roles: [ "admin:*" ]
      };

      const authResult = await Auth( {
        token: jwt.sign( tokenFixture, process.env.JWT_SECRET ),
        methodArn: 'arn:aws:execute-api:<regionId>:<accountId>:<apiId>/<stage>/<method>/<resourcePath>'
      } );

      expect( authResult ).toMatchSnapshot();
    } );
  } );
} );
