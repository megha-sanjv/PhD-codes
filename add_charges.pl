#!/usr/bin/perl
use Math::Trig;
use Math::Complex;

use strict;
use warnings;

#####################################################
#                                                   #      
#         Create a slab from a REVCON file          #
#                                                   #
#              by Samuel T. Murphy                  #
#                                                   #
#####################################################

#Open REVCON and read in to an array
open INFILE, "Li2TiO3_supercell.lmp" or die "Can't open file : Li2TiO3_10x10x10.data\n";
my @inputs = <INFILE>;
close INFILE;   

my @splitline = split(/\s+/,$inputs[2]);
my $no_atoms = $splitline[1];

#print "$no_atoms\n";
#print "xyz file generated form a REVCON file\n";

#Print header
for ($b = 0; $b<18; $b++)
{
    print $inputs[$b];
    
}
#Go through the atoms and add the charge
for (my $i=0; $i<$no_atoms; $i++)
{
        @splitline = split(/\s+/,$inputs[$i+18]);
        my $charge;
        my $atom_number = $splitline[1];
        my $atom_type = $splitline[2];
        if ($atom_type == 1)
        {
            #This is a lithium atom
            $charge = 0.549;
        }
        if ($atom_type == 2)
        {
            #This is a oxygen atom
            $charge = -1.098;
        }
        if ($atom_type == 3)
        {
            #This is a titanium atom
            $charge = 2.196;
        }
        my $x = $splitline[3];
        my $y = $splitline[4];
        my $z = $splitline[5];
                
        print "$atom_number $atom_type $charge $x $y $z\n";
}

