import Login from '../login';
import jwt from 'jsonwebtoken';

describe( 'Login', () => {
  let fixture = {};

  beforeEach( () => {
    fixture.username = 'bobpogo';
    fixture.password = 'test1';
  })

  it( '- should fail on unknown username', async () => {
    fixture.username = 'billmurphy';

    const result = await Login( fixture );
    expect( result ).toMatch( /NotFound/ );
  } );

  it( '- should fail on incorrect password', async () => {
    fixture.password = 'invalidpassword';

    const result = await Login( fixture );
    expect( result ).toMatch( /NotFound/ );
  } );

  it( '- should return a jwt token on success', async () => {
    const result = await Login( fixture );

    const decodedToken = jwt.decode( result, process.env.JWT_SECRET );

    expect( decodedToken.sub ).toBe( '1' );
    expect( decodedToken.username ).toBe( 'bobpogo' );
    expect( decodedToken.password ).toBeUndefined();
  } );
} );
