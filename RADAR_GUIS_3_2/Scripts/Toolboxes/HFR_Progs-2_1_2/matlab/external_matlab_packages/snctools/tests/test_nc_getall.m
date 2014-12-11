function test_nc_getall ( ncfile )
% TEST_NC_GETALL:  runs series of tests for nc_getall.m
%
% Relies upon nc_add_dimension, nc_addvar, nc_attput
%
% Test 1:  no input arguments, should fail
% Test 3:  dump an empty file
% Test 4:  just one dimension
% Test 5:  one fixed size variable
% Test 6:  add some global attributes
% Test 7:  another variable with attributes
% Test 8:  global attribute with "_x" attribute name



fprintf('Testing NC_GETALL ... \n' );
if nargin == 0
	ncfile = 'foo.nc';
end

test_underscore_attr ( ncfile );
test_no_inputs;
test_empty ( ncfile );
test_one_dimension ( ncfile );
test_one_fixed_size_variable ( ncfile );
test_global_attributes ( ncfile );
test_two_vars_with_atts ( ncfile );

return








%--------------------------------------------------------------------------
function test_no_inputs  ( )

try
	nc_getall;
catch %#ok<CTCH>
    return
end
error('nc_getall succeeded when it should have failed.');






%--------------------------------------------------------------------------
function test_empty ( ncfile )

create_test_file ( ncfile );
nb = nc_getall ( ncfile );
if ~isstruct ( nb )
	error ( 'result should have been a structure');
end
if ~isempty(nb)
	error('result should have been an empty structure');
end

return







%--------------------------------------------------------------------------
function test_one_dimension ( ncfile )

create_test_file ( ncfile );
nc_add_dimension ( ncfile, 'x', 6 );
nb = nc_getall ( ncfile );
if ~isstruct ( nb )
	error ('result should have been a structure');
end
if ~isempty(nb)
	error('result should have been an empty structure');
end
return









%--------------------------------------------------------------------------
function test_one_fixed_size_variable ( ncfile )

%
% Test 5:  one fixed size variable
% nb should have one field, 'x'.
% 'x' should have one field, 'data'.
create_test_file ( ncfile );
nc_add_dimension ( ncfile, 'x', 6 );

clear varstruct;
varstruct.Name = 'x';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'x' };

nc_addvar ( ncfile, varstruct );

nb = nc_getall ( ncfile );
if ~isfield(nb, 'x' )
	error('nc_getall did not return a field x.');
end
if ~isfield(nb.x, 'data' )
	error('nc_getall did not return a field x.data.');
end
return








%--------------------------------------------------------------------------
function test_global_attributes( ncfile )

%
% Test 6:  add some global attributes
% Same as Test 5, but with 6 global attributes.
create_test_file ( ncfile );
nc_add_dimension ( ncfile, 'x', 6 );

clear varstruct;
varstruct.Name = 'x';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'x' };

nc_addvar ( ncfile, varstruct );


nc_attput ( ncfile, nc_global, 'double', 3.14159 );
nc_attput ( ncfile, nc_global, 'single', single(3.14159) );
nc_attput ( ncfile, nc_global, 'int32', int32(314159) );
nc_attput ( ncfile, nc_global, 'int16', int16(31415) );
nc_attput ( ncfile, nc_global, 'int8', int8(-31) );
nc_attput ( ncfile, nc_global, 'uint8', uint8(31) );


nb = nc_getall ( ncfile );

if ~isfield(nb, 'x' )
	error('nc_getall did not return a field x.');
end
if ~isfield(nb.x, 'data' )
	error('nc_getall did not return a field x.data.');
end

if length(fieldnames(nb.global_atts)) ~= 6
	error('nc_getall did not return 6 global atts.');
end
return





%--------------------------------------------------------------------------
function test_two_vars_with_atts ( ncfile )

create_test_file ( ncfile );
nc_add_dimension ( ncfile, 'x', 6 );

clear varstruct;
varstruct.Name = 'x';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'x' };

nc_addvar ( ncfile, varstruct );


nc_attput ( ncfile, nc_global, 'double', 3.14159 );
nc_attput ( ncfile, nc_global, 'single', single(3.14159) );
nc_attput ( ncfile, nc_global, 'int32', int32(314159) );
nc_attput ( ncfile, nc_global, 'int16', int16(31415) );
nc_attput ( ncfile, nc_global, 'int8', int8(-31) );
nc_attput ( ncfile, nc_global, 'uint8', uint8(31) );


nc_add_dimension ( ncfile, 'time', 0 );

clear varstruct;
varstruct.Name = 'y';
varstruct.Nctype = 'float';
if getpref('SNCTOOLS','PRESERVE_FVD',false)
	varstruct.Dimension = {'x', 'time'};
else
	varstruct.Dimension = { 'time', 'x' };
end
varstruct.Attribute(1).Name = 'long_name';
varstruct.Attribute(1).Value = 'long_name';
varstruct.Attribute(2).Name = 'double';
varstruct.Attribute(2).Value = double(32);
varstruct.Attribute(3).Name = 'float';
varstruct.Attribute(3).Value = single(32);
varstruct.Attribute(4).Name = 'int';
varstruct.Attribute(4).Value = int32(32);
varstruct.Attribute(5).Name = 'int16';
varstruct.Attribute(5).Value = int16(32);
varstruct.Attribute(6).Name = 'int8';
varstruct.Attribute(6).Value = int8(32);
varstruct.Attribute(7).Name = 'uint8';
varstruct.Attribute(7).Value = uint8(32);

nc_addvar ( ncfile, varstruct );

nb = nc_getall ( ncfile );

if ~isfield(nb, 'y' )
	error('nc_getall did not return a field y.');
end
if length(fieldnames(nb.y)) ~= 8
	error('nc_getall did not return all the attributes of y.');
end




return










%--------------------------------------------------------------------------
function test_underscore_attr ( ncfile )

create_test_file ( ncfile );
nc_add_dimension ( ncfile, 'x', 6 );

clear varstruct;
varstruct.Name = 'x';
varstruct.Nctype = 'double';
varstruct.Dimension = { 'x' };

nc_addvar ( ncfile, varstruct );

nc_attput ( ncfile, nc_global, '_x', 0 );

nc_getall ( ncfile );


return











%--------------------------------------------------------------------------
function create_test_file(ncfile)

if snctools_use_tmw
	ncid_1 = netcdf.create(ncfile, nc_clobber_mode );
	netcdf.close(ncid_1);
else
	%
	% ok, first create the first file
	[ncid_1, status] = mexnc ( 'create', ncfile, nc_clobber_mode );
	if ( status ~= 0 )
		ncerr_msg = mexnc ( 'strerror', status );
        error(ncerr_msg);
	end
	
	%
	% CLOSE
	status = mexnc ( 'close', ncid_1 );
	if ( status ~= 0 )
		error ( 'CLOSE failed' );
	end
end
return

