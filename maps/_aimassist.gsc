#include maps\_utility;
#include common_scripts\utility;

AimAssist()
{
	self endon("disconnect");
    self waittill( "spawned_player" );

    self thread is_player_aiming();
    for(;;)
	{
		view_pos = self GetWeaponMuzzlePoint();
        zombies = get_array_of_closest( view_pos, getaiarray( "axis" ), undefined, undefined, undefined );
        range_squared = 300 * 300;
        for ( i = 0; i < zombies.size; i++ )
		{
			if ( !IsDefined( zombies[i] ) || !IsAlive( zombies[i] ) )
			{
				continue;
			}
            enemy_origin = zombies[i].origin;
            test_range_squared = DistanceSquared( view_pos, enemy_origin );
			if ( test_range_squared < range_squared )
            {
                if(zombies[i] player_can_see_me(self))
				{
					if(self adsButtonPressed() && !self isplayerreloading() && !self.isAiming )
					{
						self setPlayerAngles(vectorToAngles((zombies[i] getTagOrigin("j_spine4")) - (self getEye())));
						while(self adsButtonPressed())
						{
							wait .05;	
						}
						break;
					}
				}
            }
        }
        wait .05;
    }
}

player_can_see_me( player )
{
    playerangles = player getplayerangles();
    playerforwardvec = anglesToForward( playerangles );
    playerunitforwardvec = vectornormalize( playerforwardvec );
    banzaipos = self.origin;
    playerpos = player getorigin();
    playertobanzaivec = banzaipos - playerpos;
    playertobanzaiunitvec = vectornormalize( playertobanzaivec );
    forwarddotbanzai = vectordot( playerunitforwardvec, playertobanzaiunitvec );
    if ( forwarddotbanzai >= 1 )
    {
        anglefromcenter = 0;
    }
    else if ( forwarddotbanzai <= -1 )
    {
        anglefromcenter = 180;
    }
    else
    {
        anglefromcenter = acos( forwarddotbanzai );
    }
    playerfov = getDvarFloat( "cg_fov" );
    banzaivsplayerfovbuffer = getDvarFloat( "g_banzai_player_fov_buffer" );
    if ( banzaivsplayerfovbuffer <= 0 )
    {
        banzaivsplayerfovbuffer = 0.2;
    }
    playercanseeme = anglefromcenter <= ( ( playerfov * 0.25 ) * ( 1 - banzaivsplayerfovbuffer ) );
    return playercanseeme;
}

is_player_aiming()
{
	self.isAiming = 0;
	for(;;)
	{
		aiming = 0;
		self.isAiming = 0;
		while(self adsbuttonpressed())
		{
			aiming++;
			if(aiming > 1)
			{
				self.isAiming = 1;
			}
			wait .05;
		}
		wait .05;
	}
}