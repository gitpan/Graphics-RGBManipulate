package Graphics::RGBManipulate;

# Todo
# - write some tests 
# - write some examples

$VERSION = "0.01";
use strict; 

sub tweak {

	# Read in the config options	
	my %options = @_;
	
	my $hex_hash_flag;
	
	# If $options{'hex'} is set, overwrite $options{'red', 'green', and 'blue'}
	# with the expanded value of it.
	if ($options{'hex'}) {
		
		$hex_hash_flag = $options{'hex'} =~ s/#//;
		
		if (length $options{'hex'} == 3) {
			$options{'hex'} =~ s/([a-zA-Z0-9])/$1$1/g;
		}
		
		$options{'red'}   = hex(substr($options{'hex'}, 0, 2) );
		$options{'green'} = hex(substr($options{'hex'}, 2, 2) );
		$options{'blue'}  = hex(substr($options{'hex'}, 4, 2) );		
			
	}
	
	my ($h, $s, $v) = RGBtoHSV($options{'red'}, $options{'green'}, $options{'blue'});
	
	$h = $options{'hue'} if exists $options{'hue'};
	$s = $options{'saturation'} if exists $options{'saturation'};	
	$v = $options{'value'} if exists $options{'value'};
	
	my ($r, $g, $b) = HSVtoRGB($h, $s, $v);
	$r = round($r); $g = round($g); $b = round($b);
	
	if ($options{'hex'}) {
	
		my $hexstring = sprintf("%02X", $r) . sprintf("%02X", $g) . sprintf("%02X", $b);
		return "#" . $hexstring if $hex_hash_flag;
		return $hexstring;
	
	} else {
	
		return($r, $g, $b);
	
	}
	
}


sub round {

	my $number = $_[0];
	my $integer = int($number);
	return $integer if ($integer + 0.5 > $number);
	return ++$integer;	

}

# Return the smallest value from a list
sub min {

	my @values = sort {$a <=> $b} (@_);
	return shift @values;

}

# Return the largest value from a list
sub max {

	my @values = sort {$a <=> $b} (@_);
	return pop @values;

}

# Accepts a list with three elements, integers between 0 and 255
sub RGBtoHSV {

	my ($red, $green, $blue) = @_;
	my ($hue, $saturation, $v);

	my $min = min($red, $green, $blue);
	my $max = max($red, $green, $blue);

	# The value is the highest of the RGB values
	my $v = $max;

	my $delta = $max - $min;

	# If we have a colour (thus aren't grey), then work out the saturation
	if ($delta) {
	
		$saturation = $delta / $max;

	# We're a grey, so do the right thing
	} else {
	
		$saturation = 0;
		$hue = 0;
		return ($hue, $saturation, $v);
	
	}

	# How we calculate hue depends on which was the largest RGB value
	if ($red == $max) {

		$hue = ( $green - $blue ) / $delta;

	} elsif ( $green == $max ) {

		$hue = 2 + ($blue - $red) / $delta;
	
	} else {

		$hue = 4 + ($red - $green) / $delta;

	}

	# Change hue to degrees on the colour wheel
	$hue *= 60;
	
	# Make sure hue is a positive number
	$hue += 360 if ($hue < 0);

	return ($hue, $saturation, $v);
	
}

# Accepts a list of three values: hue is 0 to 360, saturation is 0 to 1, and value is 0 to 255
sub HSVtoRGB {

	my ($hue, $saturation, $v) = @_;
	my ($red, $green, $blue);

	# If there's no saturation, then we're a grey
	unless ($saturation) {
		$red = $green = $blue = $v;
		return ($red, $green, $blue);
	}

	$hue /= 60;
	my $i = int( $hue );
	my $f = $hue - $i;
	my $p = $v * ( 1 - $saturation );
	my $q = $v * ( 1 - $saturation * $f );
	my $t = $v * ( 1 - $saturation * ( 1 - $f ) ); 


	   if ($i == 0) { return( $v, $t, $p ) }
	elsif ($i == 1) { return( $q, $v, $p ) }
	elsif ($i == 2) { return( $p, $v, $t ) }
	elsif ($i == 3) { return( $p, $q, $v ) }
	elsif ($i == 4) { return( $t, $p, $v ) }
	           else { return( $v, $p, $q ) } 


}
1;

__END__

=head1 NAME

Graphics::RGBManipulate - HSV adjustment tool for RGB colours

=head1 SYNOPSIS

	use Graphics::RGBManipulate;
	
	my ($red, $green, $blue) = Graphics::RGBManipulate::tweak(
		hue => 40,
		red => 255,
		green => 0,
		blue => 0
	); # Changes the colour RGB(255, 0, 0) into bright orange
	
	my $hex_string = Graphics::RGBManipulate::tweak(
		hex => $old_hex_string,
		saturation => 0
	); # Returns what $old_hex_string would be as greyscale
	
=head1 METHODS

=head2 tweak

Adjusts hue, saturation and value for RGB colours. The function
accepts the following arguments (passed as a list of pairs (i.e.
a hash):

=over 2

=item hex

This should be either a three or six character hex string as found
in HTML. The preceeding # is optional, and the value you get back
will either include or not include it depending on if you included
it. If this value is set, you will get back a string rather than
an R G B list - it also overrides any red, green, or blue arguments
you may pass to C<&tweak>.

=item red/green/blue

These are values from 0 to 256. They will default to 0. If you invoke
&tweak using these values (as opposed to C<hex>) then you'll get a list
of the I<tweaked> R G B values back. 

=item hue 

If you set this, then the RGB colour will be changed to this hue.
If you don't set it, then the hue of the original colour will be
preserved. It accepts a degree on the colour wheel - any integer
from 0 to 360.

=item saturation

As with hue, if this is set, the saturation of the colour will be 
changed. Saturation can be an integer from 0 to 255. Setting it to
0 will render greyscale.

=item value

As with hue and saturation, if this is set, then the I<value> of the
colour will be adjusted. If you've not come across the concept of I<value>
before, consider it to be the inverse measure of black paint you would
mix with a colour. That is, if the value is 0, then the colour will be 
black regardless of hue and saturation. If the value is 1, then the colour
will be I<pure>... I<value> accepts a percentage in decimal form - that is
any number from 0 to 1 (e.g. 0.09).

=back

=head1 AUTHOR

Pete Sergeant - pete@clueball.com

=head1 COPYRIGHT

Copyright (c) 2002 Peter Sergeant. All rights reserved. This program is free
software; you can redistribute it and/or modify it under the same terms
as Perl itself.

=cut
