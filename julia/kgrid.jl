#! /usr/bin/env julia

################ JULIA implementation of k-grid ################
#
#                   So far just POSCAR files! 
# 
################################################################

# The ArgParse module is not included by default, needs to be installed with
# Pkg.add("ArgParse") from Julia terminal
using ArgParse

# There is a stream-based file parser which might be more more efficient
# than reading in the whole file as we do here. Couldn't figure out an
# elegant way of ripping the desired lines straight into a list, however.
# I need to get more familiar with Julia list comprehensions, which seem to
# be just as powerful as Python's.

function read_poscar(filename)
    # Read lattice vector lines from POSCAR file,
    # convert to a 3-vector of 3-vectors with a double list comprehension
    poscar = open(filename)
    lattice_lines = readlines(poscar)[3:5]
    close(poscar)
    return [[ float(x) for x=split(lattice_lines[i])] for i=1:3]
end

# For the actual calculator, division and ceiling are combined with the "cld" function,
# and norm is a built-in, making for a very terse function!
# Note that the formatted print is a macro rather than a function. This is related to
# compile-time processing of the format specifier
function kgrid(filename; cutoff=10)
    v1, v2, v3 = read_poscar(filename)
    for v in (v1, v2, v3)
        # cld is "ceiling division"
        @printf("%d ", cld((2*cutoff), norm(v)))
    end
    print('\n')
end

# ArgParse seems to be the package to use for command-line args
# The syntax is a bit funky, because it's macro-based
function parse_commandline()
    s = ArgParseSettings()
    @add_arg_table s begin
        "--cutoff", "-c"
        help = "k-point cutoff in Angstroms"
        default = 10.
        "filename"
        help = "Path to POSCAR or other recognized geometry file"
        required = true
        default = "POSCAR"
    end

    return parse_args(s)
end

function main()
    parsed_args = parse_commandline()
    kgrid(parsed_args["filename"], cutoff=float(parsed_args["cutoff"]))
end

main()
