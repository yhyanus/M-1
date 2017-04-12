------------------------------------------------------------------------------
--                                                                          --
--                    SYSTEM M-1 MODULE MKOPTIONS                           --
--                                                                          --
--                                 M-1                                      --
--                                                                          --
--                               B o d y                                    --
--                                                                          --
--         Copyright (C) 2017 Mario Blunk, Blunk electronic                 --
--                                                                          --
--    This program is free software: you can redistribute it and/or modify  --
--    it under the terms of the GNU General Public License as published by  --
--    the Free Software Foundation, either version 3 of the License, or     --
--    (at your option) any later version.                                   --
--                                                                          --
--    This program is distributed in the hope that it will be useful,       --
--    but WITHOUT ANY WARRANTY; without even the implied warranty of        --
--    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         --
--    GNU General Public License for more details.                          --
--                                                                          --
--    You should have received a copy of the GNU General Public License     --
--    along with this program.  If not, see <http://www.gnu.org/licenses/>. --
------------------------------------------------------------------------------

--   Please send your questions and comments to:
--
--   info@blunk-electronic.de
--   or visit <http://www.blunk-electronic.de> for more contact data
--
--   history of changes:
--


with ada.text_io;				use ada.text_io;
with ada.characters.handling; 	use ada.characters.handling;
with ada.containers;        	use ada.containers;
with ada.containers.vectors;
with ada.containers.indefinite_vectors;

--with ada.strings.unbounded; use ada.strings.unbounded;
with ada.strings.bounded; 		use ada.strings.bounded;
with ada.strings.fixed; 		use ada.strings.fixed;
with ada.strings; 				use ada.strings;
with ada.exceptions; 			use ada.exceptions;
 
with ada.command_line;			use ada.command_line;
with ada.directories;			use ada.directories;

with csv;
with m1_base; 					use m1_base;
with m1_string_processing;		use m1_string_processing;
with m1_database;				use m1_database;
with m1_files_and_directories;	use m1_files_and_directories;

procedure mkoptions is

	use type_name_database;
	use type_name_file_options;
	use type_name_file_routing;

	use type_device_name;
	use type_pin_name;	
	
	version			: String (1..3) := "030";
	
	prog_position	: natural := 0;

	conpair_ct			: Natural := 0;
	bridge_ct			: Natural := 0;		

-- 	type single_joker is
-- 		record
-- 			name		: unbounded_string;
-- 			len			: natural;
-- 		end record;
-- 	type joker_array is array (natural range 1..10) of single_joker;
-- 	joker_list			: joker_array;
-- 	joker_ct		 	: natural := 0;
-- 	joker_names			: unbounded_string;
	

	


-- 	type cluster is
-- 		record
-- 			ordered			: boolean := false;
-- 			bs				: boolean := false; -- bs capable flag
-- 			size			: natural := 0;
-- 			members			: unbounded_string;
-- 		end record;
-- 	type cluster_list_type is array (natural range <>) of cluster;

---------------------------------------------
-- 
-- 	function count_connector_pairs
-- 		(
-- 		-- version 1.0 / MBL
-- 		dummy	: Boolean := false
-- 		) return Natural is
-- 		
-- 		con_ct	: Natural := 0;
-- 		Line	: unbounded_string;
-- 
-- 		begin
-- 			--prog_position := "CCP"; 
-- 			Set_Input(options_conf_connectors); -- set data source
-- 			reset(options_conf_connectors); -- reset data source
-- 			-- count connector pairs
-- 			while not End_Of_File
-- 				loop
-- 					Line:=Get_Line;
-- 					if Get_Field_Count(Line) > 0 then
-- 						if Get_Field_Count(Line) = 1 then
-- 							put("ERROR : In file 'mkoptions.conf' device '" & Get_Field(Line,1) & "' has no counterpart !"); new_line;
-- 							con_ct := 0;
-- 							return con_ct;
-- 						elsif Get_Field_Count(Line) > 2 then
-- 							put("ERROR : In file 'mkoptions.conf' only one counterpart allowed for device '" & Get_Field(Line,1) & "'!"); new_line;
-- 							con_ct := 0;
-- 							return con_ct;
-- 						else
-- 							con_ct := con_ct + 1;
-- 						end if;						
-- 					
-- 					end if;				
-- 				end loop;
-- 			return con_ct;
-- 		end count_connector_pairs;
-- 
-- 
-- 	function count_bridges
-- 		(
-- 		-- version 1.0 / MBL
-- 		dummy	: Boolean := false
-- 		) return Natural is
-- 		
-- 		bridge_ct			: Natural := 0;
-- 		array_ct			: natural := 0; -- counts occurences of resistor arrays (or the like) -- ins v027
-- 		Line				: unbounded_string;
-- 		l					: natural;
-- 		bridges_detected_by_jokers 	: natural := 0;
-- 
-- 			function verify_jokers
-- 				return natural is
-- 				net_entered			: boolean := false;
-- 				part				: unbounded_string;
-- 				jokers_occured		: unbounded_string;
-- 
-- 				function count_bridges_by_jokers
-- 					(
-- 					jokers_occured	: unbounded_string  -- this is a random collection of bridge names 
-- 														-- as they appear in the netlist.
-- 														-- a name will occur once, twice but should never 
-- 														-- be there more than two times.
-- 					) return natural is					-- the result of this function is the real number of
-- 														-- bridges and a global unbounded_string with the bridge
-- 														-- names chained (joker_names)
-- 					name	: unbounded_string;
-- 					fp_init	: natural := 1;
-- 					fp		: natural := 1;
-- 					ct		: natural := 0;
-- 					bridge_ct: natural := 0;
-- 					field_ct: natural := get_field_count(jokers_occured);
-- 					type processed is array (natural range 1..field_ct) of boolean;
-- 					processed_list	: processed := (1..field_ct => false);
-- 				begin -- count_bridges_by_jokers
-- 					put_line(standard_output,ascii.lf & "counting bridges by wildcards ...");
-- 					for fp_init in 1..field_ct
-- 					loop
-- 						--fp := fp_init;
-- 						if processed_list(fp_init) = false then -- skip names already processed
-- 							--processed_list(fp_init) := true;
-- 							name := to_unbounded_string(get_field(jokers_occured,fp_init)); -- fetch name from jokers_occured
-- 							ct := 1; -- since this is the first occurence of name -> counter + 1
-- 							for fp in fp_init+1..field_ct -- loop from fp_init+1 to last field in jokers_occured
-- 							loop
-- 								if get_field(jokers_occured,fp) = name then -- on match
-- 									processed_list(fp) := true; -- mark field as processed
-- 									ct := ct + 1; -- on each occurence counter + 1
-- 									if ct > 2 then 
-- 										put_line(standard_output,"ERROR : Device " & name & " supposed to be a bridge has more than 2 pins.");
-- 										return 0; 
-- 									end if;  -- abort if more than 2 occurences
-- 								end if;
-- 							end loop;
-- 							--put_line(standard_output,name);
-- 							bridge_ct := bridge_ct + 1;
-- 							put(standard_output,natural'image(bridge_ct) & ascii.cr);
-- 							joker_names := joker_names & " " & name; -- add name to joker_name list
-- 						end if;
-- 					end loop;
-- 					new_line(standard_output);
-- 					return get_field_count(joker_names);
-- 				end count_bridges_by_jokers;
-- 
-- 			begin -- verify_jokers
-- 				--prog_position := "VJO"; 
-- 				Set_Input(netlist_file);
-- 				--bridge_ct := 2;
--  				put("-- bridge wildcards : "); -- & joker_list(joker_ct).name);
-- 				for j in 1..joker_ct
-- 				loop
-- 					put(joker_list(j).name & "* ");  -- write joker name in opt file
-- 					reset(netlist_file);
-- 					--prog_position := "VJ1"; 
-- 					while not End_Of_File -- read netlist once for each joker
-- 					loop
-- 						Line:=Get_Line;
-- 						if Get_Field_Count(Line) > 0 then 
-- 							if get_field(line,1) = "EndSubSection" then	net_entered := false; end if;
-- 							if net_entered then
-- 						--		prog_position := "VJ2"; 
-- 								--new_line; put_line("jokers occured " & jokers_occured);
-- 								if length(to_unbounded_string(get_field(Line,1))) >= joker_list(j).len then
-- 									part := to_unbounded_string(get_field(Line,1)(1..joker_list(j).len));
-- 									--new_line; put_line("part " & part);
-- 							--		prog_position := "VJ3"; 
-- 									if part = joker_list(j).name then -- on joker match
-- 										-- add full part name to jokers_occured
-- 										jokers_occured := jokers_occured & " " & get_field(line,1);
-- 										--new_line; put_line(jokers_occured);
-- 									end if;
-- 								end if;
-- 							end if;
-- 
-- 							-- if net section begin found
-- 							if is_field(Line,"SubSection",1) then net_entered := true; end if;
-- 						end if;		
-- 					end loop;
-- 
-- 				end loop;
-- 				new_line;
-- 				--new_line; put_line(jokers_occured);
-- 				-- count bridges by jokers_occured
-- 				return count_bridges_by_jokers(jokers_occured);
-- 			end verify_jokers;
-- 			
-- 
-- 		begin -- count_bridges
-- 			--prog_position := "CBR"; 
-- 			Set_Input(options_conf_bridges); -- set data source
-- 			reset(options_conf_bridges); -- reset data source
-- 			-- count bridges
-- 			while not End_Of_File
-- 				loop
-- 					Line:=Get_Line;
-- 					if Get_Field_Count(Line) > 0 then
-- 						if Get_Field_Count(Line) > 1 then
-- 							-- ins v027 begin
-- 							if get_field(line,2) = "array" then -- if array specified like "RN1 array 1-8 2-7"
-- 								-- increment bridge count by each occurencd of a field like 1-8 or 2-7
-- 								-- array name like "RN1" and keyword "array" are to be ignored, so -2 required
-- 								-- a single resistor of an array is to be counted like a discrete bridge
-- 								bridge_ct := bridge_ct + (get_field_count(line) - 2);
-- 								array_ct := array_ct + 1; -- for statistics count arrays too
-- 							else
-- 							-- ins v027 end
-- 								put("ERROR : In file 'mkoptions.conf' device '" & Get_Field(Line,1) & "' must have no further options !"); new_line;
-- 								bridge_ct := 0;
-- 								return bridge_ct;
-- 							end if; -- ins v027
-- 						else
-- 							-- test for jokers
--  							l := length(to_unbounded_string(Get_Field(Line,1)));
-- 							--put_line(standard_output,natural'image(l));
-- 				--			prog_position := "CB1"; 
--  							if (Get_Field(Line,1)(l)) = '*' then 
-- -- 								prog_position := "CB2"; 
-- 								joker_ct := joker_ct + 1; -- count jokers in global variable joker_ct
-- 
-- 								-- fill joker_list array
-- -- 								prog_position := "CB3"; 
-- 								joker_list(joker_ct).name := to_unbounded_string(Get_Field(Line,1)(1..l-1));
--  								joker_list(joker_ct).len := length(joker_list(joker_ct).name);
-- 								--put_line(standard_output,natural'image(joker_list(joker_ct).len));
-- -- 								prog_position := "CB4"; 
--  							else
-- 
-- 							-- if normal bridges are defined, count bridges
-- 								--part := to_unbounded_string(get_field(Line,1)(1..joker_list(j).len));
-- 								--if part = joker_list(j).name then -- on joker match
-- 								-- CS: make sure a discrete bridge has not been specified by a wildcard above !!
-- 								bridge_ct := bridge_ct + 1;
-- 							end if;
-- 						end if;						
-- 					end if;				
-- 				end loop;
-- 
-- -- 			prog_position := "CB5"; 
-- 			put_line("-- discrete bridges : " & trim(natural'image(bridge_ct),left));
-- 			put_line("-- resistor arrays  : " & trim(natural'image(array_ct),left)); -- ins v027
-- 			-- if jokers have been detected, they need verification, the result is the bridge count yielded from the joker definition
-- 			if joker_ct > 0 then 
-- -- 				prog_position := "CB8"; 
-- 				bridges_detected_by_jokers := verify_jokers;
-- -- 				prog_position := "CB7"; 
-- 				if bridges_detected_by_jokers = 0 then
-- -- 					prog_position := "BJC";
-- 					raise constraint_error;
-- 				end if;
-- 			end if;
-- -- 			prog_position := "CB6"; 
-- 			put_line("-- wildcard bridges : " & trim(natural'image(bridges_detected_by_jokers),left));
-- 			put_line("-- bridges total    : " & trim(natural'image(bridge_ct + bridges_detected_by_jokers),left));
-- 			return bridge_ct + bridges_detected_by_jokers;
-- 		end count_bridges;
-- 
-- 
-- 
-- 	function make_bridge_list
-- 		return bridge_list_type is
-- 
-- 		Line		: unbounded_string;
-- 		scratch		: natural := 0;
-- 		l			: natural := 0;
-- 
-- 		subtype bridge_list_sized is bridge_list_type (1..bridge_ct); bridge_list : bridge_list_sized; -- instantiate bridge list
-- 
-- 		begin
-- -- 			prog_position := "MBL";
-- 			Set_Input(options_conf_bridges); -- set data source
-- 			reset(options_conf_bridges);
-- 			while not End_Of_File
-- 				loop
-- 					Line:=Get_Line;
-- --						if Get_Field_Count(Line) > 0 then -- rm v027
-- 						if Get_Field_Count(Line) = 1 then -- ins v027
-- 							-- read discrete specified bridges only
--  							l := length(to_unbounded_string(Get_Field(Line,1)));
--  							if (Get_Field(Line,1)(l)) = '*' then null; -- if joker found do nothing
-- 							else -- its a regular bridge (like a single resistor or a wire)
-- 								scratch := scratch + 1;
-- 								bridge_list(scratch).id := scratch;	-- assign bridge id to this very bridge
-- 								bridge_list(scratch).name := to_unbounded_string(get_field(line,1)); -- assign name to this very bridge
-- 							end if;
-- 						--end if; -- rm v027
-- 
-- 						-- ins v027 begin
-- 						-- process resistor arrays specified by keyword "array" in 2nd field of line
-- 						elsif get_field_count(line) > 2 and get_field(line,2) = "array" then
-- 							for l in 3..get_field_count(line) -- for each resistor path like 1-8 or 2-7
-- 							loop
-- 								scratch := scratch + 1; -- increment scratch and
-- 								bridge_list(scratch).id := scratch;	-- assign an id to this very resitor path
-- 								-- assign name, even if name repeats because it is a resistor array
-- 								bridge_list(scratch).name := to_unbounded_string(get_field(line,1)); 
-- 								bridge_list(scratch).part_of_array := true; -- mark bridge as part of a resistor array
-- 								
-- 								-- extract pins of resitor path
-- 								bridge_list(scratch).pin_a := split_line
-- 																( 
-- 																line => to_unbounded_string( get_field(line,l) ), -- l points to current path of array
-- 																ht => true, -- request header of path. example if path is 1-8, 
-- 																			-- the header is 1 which becomes pin a
-- 																ifs => '-'	-- separator of pin a and b is a minus sign
-- 																);
-- 
-- 								bridge_list(scratch).pin_b := split_line
-- 																( 
-- 																line => to_unbounded_string( get_field(line,l) ), -- l points to current path of array
-- 																ht => false, -- request trailer of path. example if path is 1-8, 
-- 																			-- the trailer is 8 which becomes pin b
-- 																ifs => '-'	-- separator of pin a and b is a minus sign
-- 																);
-- 
-- 							end loop;
-- 						end if;
-- 						-- ins v027 end
-- 				end loop;
-- 
-- 			-- if joker bridges specified, the names listed in global variable "joker_names" must be added to array "bridge_list"
-- 			if joker_ct > 0 then
-- 				for j in 1..get_field_count(joker_names)
-- 				loop
-- 					scratch := scratch + 1; -- update bridge id
-- 					bridge_list(scratch).id := scratch;	-- assign bridge id
-- 					bridge_list(scratch).name := to_unbounded_string(get_field(joker_names,j)); -- assign name from joker_names list
-- 				end loop;
-- 			end if;
-- 
-- 			return bridge_list;
-- 		end make_bridge_list;	
-- 
-- 
-- 
-- 	function make_netlist
-- 		(
-- 		con_pair_list_in	: conpair_list_type;
-- 		bridge_list_in		: bridge_list_type
-- 		) --return netlist_type is
-- 		return boolean is
-- 
-- 		con_pair_list	: conpair_list_type := con_pair_list_in;
-- 		bridge_list		: bridge_list_type := bridge_list_in;
-- 
-- 		Line		: unbounded_string;
-- 		scratch		: natural := 0;
-- 		net_entered : boolean := false;
-- 
-- 		net_pt				: Natural := 0;
-- 		cluster_ct			: Natural := 0;
-- 		cluster_size		: Natural := 0;
-- 		part_pt				: Natural := 0;
-- 		part				: unbounded_string;
-- 		pin 				: unbounded_string;
-- 
-- 		subtype netlist_sized is netlist_type (1..net_ct); netlist : netlist_sized; -- instantiate netlist
-- 
-- 		function is_conpair
-- 		(
-- 		part_name	: string
-- 		) return boolean is
-- 		begin
-- 			for c in 1..conpair_ct
-- 			loop
-- 				if    con_pair_list(c).name_a = part_name then
-- 						con_pair_list(c).pin_ct_a := con_pair_list(c).pin_ct_a + 1;
-- 						return true;
-- 				elsif con_pair_list(c).name_b = part_name then 
-- 						con_pair_list(c).pin_ct_b := con_pair_list(c).pin_ct_b + 1;
-- 						return true; 
-- 				end if;
-- 				-- CS: count pins ?
-- 			end loop;
-- 			return false;
-- 		end is_conpair;
-- 
-- 		function is_bridge
-- 		(
-- 		part_name	: string
-- 		) return boolean is
-- 		begin
-- -- 			prog_position := "ISB";
-- 			for b in 1..bridge_ct
-- 			loop	-- CS: things could speed up if bridge has a marker like "processed"
-- 				if bridge_list(b).name = part_name then
-- 					if bridge_list(b).part_of_array = false then -- ins v027 -- to the pin count check for single bridges only
-- 
-- 						-- process a single discrete bridge
-- 						bridge_list(b).pin_ct := bridge_list(b).pin_ct + 1; 
-- 						if bridge_list(b).pin_ct > 2 then
-- 							put_line(standard_output,"ERROR : More than 2 pins found at discrete specified bridge " & part_name & " !"); 
-- -- 							prog_position := "BPC";
-- 							raise constraint_error;
-- 						end if;
-- 
-- 						-- assign pin names according to the pins found
-- 						if    length(bridge_list(b).pin_a) = 0 then bridge_list(b).pin_a := to_unbounded_string(get_field(line,5));
-- 						elsif  length(bridge_list(b).pin_b) = 0 then bridge_list(b).pin_b := to_unbounded_string(get_field(line,5));
-- 						else null; -- CS: should we do something here ?
-- 						end if;
-- 
-- 					else -- ins v027 -- its a resistor array
-- 						-- gathering pin names is not required, as the pin names are already known from mkoptions.conf
-- 						null; -- ins v027; -- CS: should we count pins of arrays here ?
-- 					end if; -- ins v027
-- 
-- 					return true;
-- 				end if; -- if bridge_list(b).name = part_name
-- 			end loop;
-- 			return false;
-- 		end is_bridge;
-- 
-- 
-- 		function pin_processed
-- 		(
-- 		pin_list	: unbounded_string;
-- 		pin			: unbounded_string
-- 		) return boolean is
-- 
-- 		begin
-- 			--put_line("pinlist : " & pin_list);
-- 			for p in 1..get_field_count(pin_list)
-- 			loop
-- 				if pin = get_field(pin_list,p) then 
-- 					return true;
-- 				end if;
-- 			end loop;
-- 			return false;
-- 		end pin_processed;
-- 
-- 		-- prespecification only
-- 		function find_net_by_part_and_pin -- FN
-- 		(
-- 		net_id_origin	: natural;
-- 		part_given		: unbounded_string;
-- 		pin_given		: unbounded_string
-- 		) return boolean;
-- 
-- 
-- 		function find_part_by_net -- FP
-- 		(
-- 		net_id_given	: natural
-- 		) return boolean is
-- 		line 	: unbounded_string;
-- 		part	: unbounded_string;
-- 		pin 	: unbounded_string;
-- 		part_found	: boolean := false;
-- 
-- 		begin
-- 			--put_line("FP");
-- 			--put_line(standard_output,"FP : " & natural'image(net_id_given));
-- 
-- 			for net_pt in 1..net_ct	-- search net by given net_id -- FP1
-- 			loop
-- 				if netlist(net_pt).net_id = net_id_given then -- if net found
-- 					for p in 1..netlist(net_pt).part_ct	-- find conpair or bridge in net
-- 					loop
-- 						line := to_unbounded_string(get_field(netlist(net_pt).content,p,character'val(10)));
-- 						part := to_unbounded_string(get_field(line,2));
-- 						pin  := to_unbounded_string(get_field(line,6));
-- 
-- 						-- check if part is a connector pair -- FP2
-- 						for c in 1..conpair_ct
-- 						loop
-- 							if con_pair_list(c).name_a = part or con_pair_list(c).name_b = part then -- part A or B found
-- 								part_found := true; -- FP10
-- 								if pin_processed(con_pair_list(c).pins_processed,pin) = false then -- if pin not processed yet -- FP4
-- 									con_pair_list(c).pins_processed := con_pair_list(c).pins_processed & " " & pin; -- mark pin as processed
-- 
-- 									if con_pair_list(c).name_a = part then -- if part A found
-- 										--put_line(standard_output,"     con  " & part & " pin " & pin); 
-- 										if find_net_by_part_and_pin
-- 											(
-- 											net_id_origin => netlist(net_pt).net_id,
-- 											part_given => con_pair_list(c).name_b, -- part A has been found, so part B must be passed
-- 											pin_given => pin
-- 											)
-- 										then null;
-- 										end if;
-- 										exit; -- test
-- 									end if; -- if part A found
-- 
-- 									if con_pair_list(c).name_b = part then -- if part B found
-- 										--put_line(standard_output,"     con  " & part & " pin " & pin);
-- 										if find_net_by_part_and_pin
-- 											(
-- 											net_id_origin => netlist(net_pt).net_id,
-- 											part_given => con_pair_list(c).name_a, -- part B has been found, so part A must be passed
-- 											pin_given => pin
-- 											)
-- 										then null;
-- 										end if;
-- 										exit; -- test
-- 									end if; -- if part B found
-- 								end if; -- if pin not processed yet
-- 							end if; -- CS: early exit ?
-- 						end loop; -- search in conpair list
-- 
-- 						-- check if part is a bridge
-- 						for b in 1..bridge_ct
-- 						loop
-- 							if bridge_list(b).name = part then -- PF3 -- bridge found
-- 								part_found := true; -- FP10
-- 								if bridge_list(b).pin_a = pin then -- pin A found
-- 									-- this pin is connected with a net, so we mark this pin as "connected" now
-- 									bridge_list(b).pin_a_connected := true; -- ins v027
-- 									if bridge_list(b).pin_a_processed = false then -- if pin A not processed yet -- FP5
-- 										bridge_list(b).pin_b_processed := true; -- mark counter pin B as processed -- FP6
-- 										--put_line(part & " counter pin " & bridge_list(b).pin_b);  -- CS: early exit ?
-- 										if find_net_by_part_and_pin
-- 											(
-- 											net_id_origin => netlist(net_pt).net_id,
-- 											part_given => part,
-- 											pin_given => bridge_list(b).pin_b -- pin A has been found, so pin B must be passed
-- 											)
-- 											then null;
-- 										end if;
-- 									end if;
-- 
-- 								elsif bridge_list(b).pin_b = pin then -- pin B found
-- 									-- this pin is connected with a net, so we mark this pin as "connected" now
-- 									bridge_list(b).pin_b_connected := true; -- ins v027
-- 									if bridge_list(b).pin_b_processed = false then -- if pin B not processed yet -- FP5
-- 										bridge_list(b).pin_a_processed := true;	--  mark counter pin A as processed -- FP6
-- 										--put_line(part & " counter pin " & bridge_list(b).pin_a);  -- CS: early exit ?
-- 										if find_net_by_part_and_pin
-- 											(
-- 											net_id_origin => netlist(net_pt).net_id,
-- 											part_given => part,
-- 											pin_given => bridge_list(b).pin_a -- pin B has been found, so pin A must be passed
-- 											)
-- 											then null;
-- 										end if;
-- 									end if; -- if pin B not processed yet
-- 								else null; -- CS: should we do something here ? (bridge found but not pin found)
-- 								-- is this case a resistor of a resistor array has been found, but the pin does not match
-- 								-- so another looping is required to find the pin -- ins v027
-- 								end if;
-- 							end if; -- FP3 -- bridge found
-- 						end loop; -- search in bridge list
-- 
-- 
-- 					end loop; -- search in partlist of net
-- 					
-- 					if part_found then return true; -- FP11
-- 					else return false; -- implies an early exit if no conpair or bridge in net found, so no further nets will be searched in
-- 					end if;
-- 				end if; -- if net found
-- 			end loop;
-- 
-- 			return false; -- if no part found
-- 		end find_part_by_net;
-- 
-- 
-- 
-- 		function find_net_by_part_and_pin -- FN
-- 		(
-- 		net_id_origin	: natural;
-- 		part_given		: unbounded_string;
-- 		pin_given		: unbounded_string
-- 		) return boolean is
-- 		line 	: unbounded_string;
-- 		part	: unbounded_string;
-- 		pin 	: unbounded_string;
-- 		--net_pt	: natural;
-- 		begin
-- 			--put_line("FN");
-- 			--put_line("net id origin : " & trim(natural'image(net_id_origin),left));
-- 			--put_line("part given    : " & part_given);
-- 			--put_line("pin  given    : " & pin_given);
-- 
-- 
-- 			--put_line(standard_output,"FN : " & natural'image(net_id_origin));
-- 
-- 
-- 
-- 			for net_pt in 1..net_ct
-- 			loop
-- 				if netlist(net_pt).cluster_member then -- FN2
-- 					if netlist(net_pt).net_id /= net_id_origin then -- FN3
-- 
-- 						for p in 1..netlist(net_pt).part_ct
-- 						loop
-- 							line := to_unbounded_string(get_field(netlist(net_pt).content,p,character'val(10)));
-- 							part := to_unbounded_string(get_field(line,2));
-- 							pin  := to_unbounded_string(get_field(line,6));
-- 							if part = part_given and pin = pin_given then -- FN4 / FN5
-- 								if netlist(net_pt).cluster_id = 0 then -- net found has not been processed yet -- FN9
-- 									--put_line(standard_output,"    sub net  : " & netlist(net_pt).name);
-- 									netlist(net_pt).cluster_id := cluster_ct; -- FN6
-- 									if find_part_by_net(netlist(net_pt).net_id) then
-- 										null;
-- 									end if;
-- 									return true; -- if given part and pin found -- FN8
-- 								end if;
-- 							end if;
-- 						end loop;
-- 					end if;
-- 				end if;
-- 			end loop;
-- 			return false; -- if given part and pin not found -- FN9
-- 		end find_net_by_part_and_pin;
-- 
-- 
-- 		procedure find_non_cluster_bs_nets is
-- 		begin
-- 				for n in 1..net_ct
-- 				loop
-- 					if netlist(n).cluster_id = 0 then
-- 						if netlist(n).bs_driver_ct > 0 or netlist(n).bs_input_ct > 0 then
-- 							put("Section " & netlist(n).name & " class NA   -- single bs-net");
-- 							if netlist(n).bs_driver_ct = 0 then put("  -- allowed class : EH , EL"); end if;
-- 							if netlist(n).bs_input_ct = 0 then put("  -- allowed class : NR , DH , DL"); end if;
-- 							new_line;
-- 							put_line(netlist(n).content & "EndSection"); new_line;	
-- 							new_line;
-- 						end if;
-- 					end if;
-- 				end loop;
-- 			end find_non_cluster_bs_nets;
-- 
-- 		procedure find_non_cluster_non_bs_nets is
-- 		begin
-- 			-- find non-cluster non-bs nets
-- 			for n in 1..net_ct
-- 			loop
-- 				if netlist(n).cluster_id = 0 then
-- 					if netlist(n).bs_driver_ct = 0 and netlist(n).bs_input_ct = 0 then
-- 						put_line("-- Section " & netlist(n).name & " class NA   -- single non-bs net");
-- 						--put_line(netlist(n).name);
-- 						put(netlist(n).content);
-- 						put_line("-- EndSection");
-- 						new_line;
-- 					end if;
-- 				end if;
-- 			end loop;
-- 		end find_non_cluster_non_bs_nets;
-- 
-- 
-- 
-- 		procedure order_clusters is
-- 
-- 		subtype cluster_list_sized is cluster_list_type (1..cluster_ct);
-- 		cluster_list	: cluster_list_sized;
-- 
-- 			procedure order_bs_cluster
-- 				(
-- 				size	: natural;
-- 				members	: unbounded_string -- holds ids of cluster nets, separated by space
-- 				) is
-- 				primary_net_found	: boolean := false;
-- 				begin
-- 					put("Section ");
-- 	
-- 					-- search for a "must be" primary net (with output2 drivers)
-- 					loop_i1: 
-- 					for i in 1..size
-- 					loop
-- 						for n in 1..net_ct
-- 						loop
-- 							if netlist(n).processed = false then
-- 								if netlist(n).net_id = natural'value(get_field(members,i)) then -- member net found
-- 
-- 									if netlist(n).primary_net then
-- 										netlist(n).processed := true;
-- 										put_line(netlist(n).name & " class NA  -- allowed DH, DL, NR");
-- 										csv.put_field(routing_file,to_string(netlist(n).name)); -- in v028
-- 										put(netlist(n).content);
-- 										primary_net_found := true;
-- 										exit loop_i1;
-- 									end if;
-- 								end if;
-- 							end if;
-- 						end loop;
-- 					end loop loop_i1;
-- 
-- 					if primary_net_found = false then	
-- 						-- search for a primary net with normal outputs (output3, bidir)
-- 						loop_i2: 
-- 						for i in 1..size
-- 						loop
-- 							for n in 1..net_ct
-- 							loop
-- 								if netlist(n).processed = false then
-- 									if netlist(n).net_id = natural'value(get_field(members,i)) then -- member net found
-- 
-- 										if netlist(n).bs_driver_ct > 0 then
-- 											netlist(n).processed := true;
-- 											put_line(netlist(n).name & " class NA");
-- 											csv.put_field(routing_file,to_string(netlist(n).name)); -- in v028
-- 											put(netlist(n).content);
-- 											primary_net_found := true;
-- 											exit loop_i2;
-- 										end if;
-- 
-- 									end if;
-- 								end if;
-- 							end loop;
-- 						end loop loop_i2;
-- 					end if;
-- 
-- 
-- 					if primary_net_found = false then	
-- 						-- search for a primary net with inputs
-- 						loop_i3: 
-- 						for i in 1..size
-- 						loop
-- 							for n in 1..net_ct
-- 							loop
-- 								if netlist(n).processed = false then
-- 									if netlist(n).net_id = natural'value(get_field(members,i)) then -- member net found
-- 
-- 										if netlist(n).bs_input_ct > 0 then
-- 											netlist(n).processed := true;
-- 											put_line(netlist(n).name & " class NA  -- allowed class: EH , EL");
-- 											csv.put_field(routing_file,to_string(netlist(n).name)); -- in v028
-- 											put(netlist(n).content);
-- 											primary_net_found := true;
-- 											exit loop_i3;
-- 										end if;
-- 
-- 									end if;
-- 								end if;
-- 							end loop;
-- 						end loop loop_i3;
-- 					end if;
-- 
-- 					-- CS: check if primary_net_found here ?
-- 
-- 					--put_line(" Subsection secondary_nets"); -- rm v026
-- 					put_line(" SubSection secondary_nets"); -- ins v026
-- 
-- 						-- search for secondary nets
-- 						for i in 1..size
-- 						loop
-- 							for n in 1..net_ct
-- 							loop
-- 								if netlist(n).processed = false then
-- 									if netlist(n).net_id = natural'value(get_field(members,i)) then -- member net found
-- 										netlist(n).processed := true;
-- 										put_line("  Net " & netlist(n).name);
-- 										csv.put_field(routing_file,to_string(netlist(n).name)); -- in v028
-- 										put(netlist(n).content);
-- 									end if;
-- 									-- CS: what if no secondary net found ? this may happen if a bridge has open pins
-- 								end if;
-- 							end loop;
-- 						end loop;
-- 
-- 					put_line(" EndSubSection");
-- 					put_line("EndSection");
-- 					new_line(2);
-- 					csv.put_lf(routing_file); -- in v028
-- 				end order_bs_cluster;
-- 
-- 
-- 			begin
-- 				-- make cluster_list
-- 				for c in 1..cluster_ct
-- 				loop
-- 					for n in 1..net_ct
-- 					loop
-- 						if netlist(n).cluster_id = c then -- find nets belonging to the cluster
-- 							cluster_list(c).size := cluster_list(c).size + 1; -- update cluster size
-- 							cluster_list(c).members := cluster_list(c).members & " " & natural'image(netlist(n).net_id); -- collect net ids
-- 					
-- 							-- if any net of this cluster has bs input or output, mark cluster as bs capable
-- 							if netlist(n).bs_driver_ct > 0 or netlist(n).bs_input_ct > 0 then cluster_list(c).bs := true; end if;
-- 						end if;
-- 					end loop;
-- 				end loop;
-- 
-- 
-- 				-- find bs-cluster
-- 				for c in 1..cluster_ct
-- 				loop
-- 					if cluster_list(c).ordered = false then
-- 						if cluster_list(c).bs then
-- 							--put_line("-- bs cluster size : " & natural'image(cluster_list(c).size));					
-- 	--						put_line("-- bs-cluster :");
-- 							order_bs_cluster(cluster_list(c).size,cluster_list(c).members);
-- 							cluster_list(c).ordered := true;
-- 						end if;
-- 
-- 					end if;
-- 				end loop;
-- 
-- 				-- find non-cluster bs nets
-- 				find_non_cluster_bs_nets;
-- 
-- 				-- find non-bs clusters
-- 				for c in 1..cluster_ct
-- 				loop
-- 					if cluster_list(c).ordered = false then
-- 						if cluster_list(c).bs = false then
-- 							--put_line("-- cluster size : " & natural'image(cluster_list(c).size));
-- 							for i in 1..cluster_list(c).size -- i points to cluster member net_id 
-- 							loop
-- 								for n in 1..net_ct
-- 								loop
-- 									if netlist(n).net_id = natural'value(get_field(cluster_list(c).members,i)) then -- member net found
-- 										--if netlist(n).bs_driver_ct > 0 then
-- 										--netlist(n).ordered := true;
-- 										if i = 1 then
-- 											put_line("-- Section " & netlist(n).name & " class NA  -- non-bs cluster");
-- 											csv.put_field(routing_file,to_string(netlist(n).name)); -- in v028
-- 											put(netlist(n).content);
-- 											put_line(" -- SubSection secondary_nets");
-- 										else
-- 											put_line("  -- Net " & netlist(n).name);
-- 											csv.put_field(routing_file,to_string(netlist(n).name)); -- in v028
-- 											put(netlist(n).content);
-- 										end if;
-- 									end if;
-- 								end loop;
-- 							end loop;
-- 							put_line("--  EndSubSection");
-- 							put_line("-- EndSection");
-- 							new_line(2);
-- 							csv.put_lf(routing_file); -- in v028
-- 							cluster_list(c).ordered := true;
-- 						end if;
-- 					end if;
-- 				end loop;
-- 
-- 
-- 				find_non_cluster_non_bs_nets;
-- 
-- 			end order_clusters;
-- 
-- 
-- 		---- begin make_netlist
-- 		begin
-- 			Set_Input(netlist_file);
-- 			reset(netlist_file);
-- 			while not End_Of_File -- read from netlist -- mark cluster nets
-- 				loop
-- 					Line:=Get_Line;
-- 						if Get_Field_Count(Line) > 0 then 
-- 									
-- 							if get_field(line,1) = "EndSubSection" then 
-- 								net_entered := false; 
-- 								--netlist(scratch).content := (to_string(netlist(scratch).content))'last-1;
-- 							end if;
-- 
-- 
-- 							if net_entered then
-- 								-- count parts of net
-- 								netlist(scratch).part_ct := netlist(scratch).part_ct + 1; 
-- 
--  								-- compose net section line by line (with LF attached)
-- 								netlist(scratch).content := netlist(scratch).content & to_unbounded_string("   -- " & to_string(Line) & character'val(10));
-- -- 								if netlist(scratch).part_ct = 1 then
-- -- 									--netlist(scratch).content := netlist(scratch).content & to_unbounded_string("   -- " & to_string(Line) & character'val(10));
-- -- 									netlist(scratch).content := to_unbounded_string("   -- " & to_string(Line));
-- -- 								else
-- -- 									--netlist(scratch).content := netlist(scratch).content & to_unbounded_string("   -- " & to_string(Line));
-- -- 									netlist(scratch).content := character'val(10) & netlist(scratch).content & to_unbounded_string("   -- " & to_string(Line));
-- -- 								end if;
-- 
-- 								-- test for conpair or bridge, if positive, mark net as cluster_member
-- 								if is_conpair(get_field(line,1)) or is_bridge(get_field(line,1)) then 
-- 									netlist(scratch).cluster_member := true;
-- 								end if;
-- 
--  								-- count bs pins
--  								for field_pt in 6..Get_Field_Count(Line)
-- 								loop
-- 									-- count driver pins
-- 									if is_field(Line,"output2",field_pt) or is_field(Line,"output3",field_pt) or is_field(Line,"bidir",field_pt) then
-- 										netlist(scratch).bs_driver_ct := netlist(scratch).bs_driver_ct + 1;
-- 									end if;
-- 								
-- 									-- mark net as primary net
-- 									if is_field(Line,"output2",field_pt) then
-- 										netlist(scratch).primary_net := true;
-- 									end if;
-- 
-- 									-- count input pins
-- 									if is_field(Line,"input",field_pt) or is_field(Line,"clock",field_pt) or is_field(Line,"observe_only",field_pt) then
-- 										netlist(scratch).bs_input_ct := netlist(scratch).bs_input_ct + 1;
-- 									end if;
-- 								end loop;
-- 
-- 							end if;
-- 
-- 
-- 							-- if net section begin found
-- 							if is_field(Line,"SubSection",1) then
-- 								scratch := scratch + 1;
-- 								netlist(scratch).net_id := scratch;	-- assign net_id
-- 								netlist(scratch).name := to_unbounded_string(get_field(line,2)); -- assign net name
-- 								netlist(scratch).class := get_field(line,4); -- assign net class
-- 								net_entered := true;
-- 							end if;
-- 
-- 
-- 						end if;		
-- 				end loop;
-- 
-- 			--write_summary
-- 			if conpair_ct > 0 then
-- 				new_line; put_line("-- CONNECTOR PAIRS ---------------------------------------------------"); new_line;
-- 				for c in 1..conpair_ct
-- 				loop
-- 					new_line;
-- 					--put_line("-- pair id       : " & trim(natural'image(c),left));
-- 					put_line("--   name A      : " & con_pair_list(c).name_a);
-- 					put_line("--   pin count A : " & trim(natural'image(con_pair_list(c).pin_ct_a),left));
-- 					put_line("--   name B      : " & con_pair_list(c).name_b);
-- 					put_line("--   pin count B : " & trim(natural'image(con_pair_list(c).pin_ct_b),left));
-- 					if con_pair_list(c).pin_ct_a = 0 then 
-- 						put_line("-- WARNING : No nets found on " & con_pair_list(c).name_a & " !"); end if;
-- 					if con_pair_list(c).pin_ct_b = 0 then 
-- 						put_line("-- WARNING : No nets found on " & con_pair_list(c).name_b & " !"); end if;
-- 					if con_pair_list(c).pin_ct_a /= con_pair_list(c).pin_ct_b then 
-- 						put_line("-- WARNING : pin count of " & con_pair_list(c).name_a & " differs from pin count of " & con_pair_list(c).name_b & " ."); end if;
-- 				end loop;	
-- 			end if;
-- 
-- 			if bridge_ct > 0 then
-- 				new_line; put_line("-- BRIDGE LIST -------------------------------------------------------"); new_line;
-- 				put_line("--   name  pin_A - pin_B "); new_line;
-- 				for b in 1..bridge_ct
-- 				loop
-- 					put_line("--   " & bridge_list(b).name & " " & bridge_list(b).pin_a & "-" & bridge_list(b).pin_b);
-- 					if bridge_list(b).part_of_array = false then -- ins v027 -- output warnings for single bridges only
-- 						-- CS: output warnings for unconnected array pins too
-- 						if bridge_list(b).pin_ct = 0 then
-- 							put("-- WARNING : No nets found on " & bridge_list(b).name ); 
-- 							put_line(". Check bridge declaration in file mkoptions.conf !");
-- 							put_line("--           " & bridge_list(b).name & " may not exist in design."); new_line; 
-- 							-- CS: should we abort the program here  with an error message ?
-- 						end if; -- mod v027
-- 						if bridge_list(b).pin_ct = 1 then
-- 							put_line("-- WARNING : Only one net found on " & bridge_list(b).name & " ! Check design !"); new_line; 
-- 						end if;
-- 
-- 					end if; -- ins v027
-- 				end loop;	
-- 			end if;
-- 
-- 			--new_line; put_line("-- NETLIST -----------------------------------------------------------"); new_line; -- rm v027
-- 
-- 			-- search cluster nets (action AC1)
-- 			put_line(standard_output,"searching cluster nets ...");
-- 
-- 
-- 			cluster_ct := 0;
-- 			for net_pt in 1..net_ct
-- 			loop
-- 				--new_line(standard_output);
-- 				--put_line(standard_output,"--> root net : " & netlist(net_pt).name);					
-- 				put(standard_output,natural'image(cluster_ct) & ascii.cr);
-- 				if netlist(net_pt).cluster_member and netlist(net_pt).cluster_id = 0 then
-- 					cluster_ct := cluster_ct + 1;
-- 					netlist(net_pt).cluster_id := cluster_ct;
-- 					
-- 					--put_line("AC1 net name " & netlist(net_pt).name);
-- 					--new_line(standard_output);
-- 					--put_line(standard_output,"AC : " & netlist(net_pt).name);					
-- 
-- 					for p in 1..netlist(net_pt).part_ct
-- 					loop
-- 						line := to_unbounded_string(get_field(netlist(net_pt).content,p,character'val(10)));
-- 						part := to_unbounded_string(get_field(line,2));
-- 						pin  := to_unbounded_string(get_field(line,6));
-- 
-- 						-- check if part is a connector pair
-- 						for c in 1..conpair_ct
-- 						loop
-- 							if con_pair_list(c).name_a = part then -- part A found
-- 								con_pair_list(c).pins_processed := con_pair_list(c).pins_processed & " " & pin;
-- 								--put_line(part & " " & con_pair_list(c).name_b & " pin " & pin); 
-- 								--put_line(standard_output,"     con  " & part & " pin " & pin); 
-- 								if find_net_by_part_and_pin
-- 									(
-- 									net_id_origin => netlist(net_pt).net_id,
-- 									part_given => con_pair_list(c).name_b, -- part A has been found, so part B must be passed
-- 									pin_given => pin
-- 									)
-- 								then null;
-- 								exit; -- test
-- 								end if;
-- 	
-- 							end if; -- CS: early exit ?
-- 							if con_pair_list(c).name_b = part then -- part B found
-- 								con_pair_list(c).pins_processed := con_pair_list(c).pins_processed & " " & pin;
-- 								--put_line(part & " " & con_pair_list(c).name_a & " pin " & pin);
-- 								--put_line(standard_output,"     con  " & part & " pin " & pin); 
-- 								if find_net_by_part_and_pin
-- 									(
-- 									net_id_origin => netlist(net_pt).net_id,
-- 									part_given => con_pair_list(c).name_a, -- part B has been found, so part A must be passed
-- 									pin_given => pin
-- 									)
-- 								then null;
-- 								end if;
-- 								exit; -- test
-- 							end if; -- CS: early exit ?
-- 						end loop;
-- 
-- 						-- check if part is a bridge
-- 						for b in 1..bridge_ct
-- 						loop
-- 							if bridge_list(b).name = part then -- AC2
-- 								if bridge_list(b).pin_a = pin then -- pin A found
-- 									-- this pin is connected with a net, so we mark this pin as "connected" now
-- 									bridge_list(b).pin_a_connected := true; -- ins v027
-- 									bridge_list(b).pin_b_processed := true; --AC3
-- 									--put_line(part & " counter pin " & bridge_list(b).pin_b);  -- CS: early exit ?
-- 									--put_line(standard_output,"     bridge " & part & " pin " & pin); 
-- 									if find_net_by_part_and_pin
-- 										(
-- 										net_id_origin => netlist(net_pt).net_id,
-- 										part_given => part,
-- 										pin_given => bridge_list(b).pin_b -- pin A has been found, so pin B must be passed
-- 										)
-- 										then null;
-- 									end if;
-- 									exit; -- test
-- 
-- 								elsif bridge_list(b).pin_b = pin then -- pin B found -- AC4
-- 									-- this pin is connected with a net, so we mark this pin as "connected" now
-- 									bridge_list(b).pin_b_connected := true; -- ins v027
-- 									bridge_list(b).pin_a_processed := true;	-- AC5
-- 									--put_line(part & " counter pin " & bridge_list(b).pin_a);  -- CS: early exit ?
-- 									--put_line(standard_output,"     bridge " & part & " pin " & pin); 
-- 									if find_net_by_part_and_pin
-- 										(
-- 										net_id_origin => netlist(net_pt).net_id,
-- 										part_given => part,
-- 										pin_given => bridge_list(b).pin_a -- pin B has been found, so pin A must be passed
-- 										)
-- 										then null;
-- 									end if;
-- 									exit; -- test
-- 
-- 								else null; -- CS: should we do something here ?
-- 									-- in this case, a resistor of an array has been found, but the pin names do not match
-- 									-- so in the next looping another path of the array is to be examined -- ins v027
-- 								end if;
-- 							end if;
-- 						end loop;
-- 
-- 
-- 					end loop;
-- 					--new_line;
-- 
-- 				end if;
-- 			end loop;
-- 
-- 			new_line(standard_output);
-- 
-- 
-- 			-- ins v027 begin
-- 			-- check for open bridge array pins
-- -- 			prog_position := "OP1";
-- 			if bridge_ct > 0 then
-- 				for b in 1..bridge_ct
-- 				loop
-- 					if bridge_list(b).part_of_array = true then -- search in bridges for unconnected pins
-- 						if bridge_list(b).pin_a_connected = false then
-- 							put_line("-- WARNING : Bridge " & bridge_list(b).name & " has unconnected pin " & bridge_list(b).pin_a & " !");
-- 							put_line("-- Check array declaration in mkoptions.conf file !"); new_line;
-- 						end if;
-- 						if bridge_list(b).pin_b_connected = false then
-- 							put_line("-- WARNING : Bridge " & bridge_list(b).name & " has unconnected pin " & bridge_list(b).pin_b & " !"); 
-- 							put_line("-- Check array declaration in mkoptions.conf file !"); new_line; 
-- 						end if;
-- 					end if;
-- 				end loop;
-- 			end if;
-- 
-- 			new_line; put_line("-- NETLIST -----------------------------------------------------------"); new_line; -- ins v027
-- 			-- ins v027 end
-- 
-- 
-- 			if cluster_ct > 0 then 
-- 				-- order net clusters
-- 				put_line(standard_output,"ordering clusters ...");
-- 				order_clusters;
-- 			else
-- 				find_non_cluster_bs_nets;
-- 				find_non_cluster_non_bs_nets;
-- 			end if;
-- 
-- 			return true;
-- 		end make_netlist;	
-- 		
	procedure write_routing_file_header is
	begin
		set_output(file_routing);
		csv.put_field(text => "-- NET ROUTING TABLE"); csv.put_lf;
		csv.put_field(text => "-- created by mkoptions version: "); csv.put_field(text => version); csv.put_lf;
		csv.put_field(text => "-- date:"); csv.put_field(text => date_now);
		csv.put_lf(count => 2);
		set_output(standard_output);
	end write_routing_file_header;

	procedure write_options_file_header is
	begin
		set_output(file_options);
		put_line ("-- THIS IS AN OPTIONS FILE FOR " & to_upper(text_identifier_database) & row_separator_0 & to_string(name_file_database));
		put_line ("-- created by " & name_module_mkoptions & " version " & version);	
		put_line ("-- date " & date_now);
		put_line ("-- Please modifiy net classes and primary/secondary dependencies according to your needs."); 
		new_line;
		set_output(standard_output);
	end write_options_file_header;


--     length_of_device_name : constant positive := 100;
--     package type_device_name is new generic_bounded_length(length_of_device_name);
-- 	use type_device_name;
-- 
--     length_of_pin_name : constant positive := 10;
--     package type_pin_name is new generic_bounded_length(length_of_pin_name);
--     use type_pin_name;

	length_pins_of_bridge_max : constant := 1 + 2 * pin_name_length; -- for something like "1-8" or "999-999"
	package type_pins_of_bridge is new generic_bounded_length(length_pins_of_bridge_max);
	
	type type_pin is record
		name			: type_pin_name.bounded_string;
		processed		: boolean := false;
		connected		: boolean := false;
	end record;
	
	type type_bridge_preliminary is tagged record
		name			: type_device_name.bounded_string;
		wildcards		: boolean := false; -- true if name contains asterisks (*) or quesition marks (?)
		pin_a			: type_pin;
		pin_b			: type_pin;
	end record;

	type type_bridge_within_array is record -- like "1-8 2-7"
		pin_a			: type_pin;
		pin_b			: type_pin;
	end record;
	package type_list_of_bridges_within_array is new vectors 
		(index_type => positive, element_type => type_bridge_within_array);
	list_of_bridges_within_array_preliminary : type_list_of_bridges_within_array.vector;
	use type_list_of_bridges_within_array;
	
	type type_bridge ( is_array : boolean) is new type_bridge_preliminary with record
		case is_array is
			when true => list_of_bridges : type_list_of_bridges_within_array.vector;
			when false => null;
		end case;
	end record;
	package type_list_of_bridges is new indefinite_vectors 
		( index_type => positive, element_type => type_bridge);
	use type_list_of_bridges;
	list_of_bridges : type_list_of_bridges.vector;
	

	type type_connector_mapping is ( one_to_one , cross_pairwise );
	connector_mapping_default : constant type_connector_mapping := one_to_one;
	type type_connector_pair is record
		name_a			: type_device_name.bounded_string;
 		name_b			: type_device_name.bounded_string;
		pin_ct_a		: natural := 0;
		pin_ct_b		: natural := 0;
		mapping			: type_connector_mapping := one_to_one;
		-- 			pins_processed	: unbounded_string;
	end record;
	package type_list_of_connector_pairs is new vectors ( index_type => positive, element_type => type_connector_pair);
	use type_list_of_connector_pairs;
	list_of_connector_pairs : type_list_of_connector_pairs.vector;

	function has_wildcards (device : in type_device_name.bounded_string) return boolean is
		asterisks_count 		: natural := type_device_name.count(device,"*");
		question_marks_count	: natural := type_device_name.count(device,"?");
		wildcards_found			: boolean := false;
	begin
		if asterisks_count > 0 then
			wildcards_found := true;
		end if;

		if question_marks_count > 0 then
			wildcards_found := true;
		end if;
		
		return wildcards_found;
	end has_wildcards;

	function read_bridges_of_array (
		line 		: in string; -- contains something like "RN303 array 1-2 3-4 5-6 7-8"
		field_count : in positive;
		line_counter: in positive) 
		return type_list_of_bridges_within_array.vector is
		list_of_bridges : type_list_of_bridges_within_array.vector;

		use type_pins_of_bridge; 
		field : type_pins_of_bridge.bounded_string; -- something like "1-8"

		bridge 		: type_bridge_within_array;
		separator	: constant string (1..1) := "-";
 		pos_sep 	: positive; -- position of separator "-" 
	begin -- read_bridges_of_array
		for i in 3..field_count loop -- we start reading in field 3 
			field := to_bounded_string(get_field_from_line(line,i));
			if type_pins_of_bridge.count(field,separator) = 1 then -- there must be a single separator
				pos_sep 			:= type_pins_of_bridge.index(field,separator); -- get position of separator

				-- get pin names left and right of separator
				bridge.pin_a.name	:= to_bounded_string(type_pins_of_bridge.slice(field, 1, pos_sep-1));
				bridge.pin_b.name	:= to_bounded_string(type_pins_of_bridge.slice(field, pos_sep+1, length(field)));

				write_message (
					file_handle => file_mkoptions_messages,
					identation => 3,
					text => "pins: " & to_string(bridge.pin_a.name) & separator & to_string(bridge.pin_b.name),
					console => false);

				-- CS: check multiple occurences of pin names and bridges
				
				append(list_of_bridges, bridge);
				
			else
				-- put a final linebreak at end of line in logfile
				new_line (file_mkoptions_messages);
				
				write_message (
					file_handle => file_mkoptions_messages,
					text => message_error & "in line" & positive'image(line_counter) & ": " 
						& "A single separator '" & separator & "' expected between pin names ! "
						& "Example: RN4 array 1-8 2-7 3-6 4-5",
					console => true);
				raise constraint_error;
			end if;
			
		end loop;
		return list_of_bridges;
	end read_bridges_of_array;
	
	procedure read_mkoptions_configuration is
		type_line_length_max		: constant natural := 1000;
		package type_line_of_file is new generic_bounded_length(type_line_length_max); use type_line_of_file;
		line						: type_line_of_file.bounded_string;
		line_counter				: natural := 0;
		field_count					: natural;
		section_connectors_entered	: boolean := false;
		section_bridges_entered 	: boolean := false;
		
		conpair_preliminary 		: type_connector_pair;
		bridge_preliminary			: type_bridge_preliminary;
		bridge_is_array				: boolean := false;
	begin -- read_mkoptions_configuration
		write_message (
			file_handle => file_mkoptions_messages,
			text => "reading file " & name_file_mkoptions_conf & "...",
			console => true);
		
		open (file => file_mkoptions, mode => in_file, name => name_file_mkoptions_conf);
		set_input(file_mkoptions);
		while not end_of_file loop
			line 			:= to_bounded_string(remove_comment_from_line(get_line));
			line_counter	:= line_counter + 1;
			field_count		:= get_field_count(to_string(line));
			if field_count > 0 then -- skip empty lines
				--				put_line(extended_string.to_string(line));

				-- READ CONNECTORS
				if not section_connectors_entered then -- we are outside section connectors
					-- search for header of section connectors
					if get_field_from_line(to_string(line),1) = section_mark.section and
					   get_field_from_line(to_string(line),2) = options_keyword_connectors then
						section_connectors_entered := true;

						write_message (
							file_handle => file_mkoptions_messages,
							identation => 1,
							text => "connector pairs ...",
							console => true);

					end if;
				else -- we are inside section connectors

					-- search for footer of section connectors
					if get_field_from_line(to_string(line),1) = section_mark.endsection then -- we are leaving section connectors
						section_connectors_entered := false; 

						append(list_of_connector_pairs,conpair_preliminary);
					else
						-- Read names of connectors.
						-- There must be at least 2 fields per line (for connector A and B and mapping)
						if field_count > 1 then 
							conpair_preliminary.name_a	:= to_bounded_string(get_field_from_line(to_string(line),1));
							conpair_preliminary.name_b	:= to_bounded_string(get_field_from_line(to_string(line),2));

							-- report names in logfile
							write_message (
								file_handle => file_mkoptions_messages,
								identation => 2, 
								text => "A " & to_string(conpair_preliminary.name_a) 
									& " B " & to_string(conpair_preliminary.name_b),
								lf => false,
								console => false);

							-- If mapping provided in a 3rd field, read it and report in logfile. 
							-- If not provided, assume default mapping.
							if field_count > 2 then
								conpair_preliminary.mapping	:= type_connector_mapping'value(get_field_from_line(to_string(line),3));
								-- CS: helpful message when invalid mapping
							else
								conpair_preliminary.mapping := connector_mapping_default;
							end if;

							write_message (
								file_handle => file_mkoptions_messages,
								identation => 1, 
								text => "mapping " & type_connector_mapping'image(conpair_preliminary.mapping),
								console => false);
						else
							-- put a final linebreak at end of line in logfile
							new_line (file_mkoptions_messages);
							
							write_message (
								file_handle => file_mkoptions_messages,
								text => message_error & "in line" & positive'image(line_counter) & ": " 
									& "Connector pair expected ! "
									& "Example: main_X1 sub_X1",
								console => true);
							raise constraint_error;

						end if;
					end if;
				end if;

				-- READ BRIDGES
				if not section_bridges_entered then -- we are outside sectin bridges
					-- search for header of section bridges
					if get_field_from_line(to_string(line),1) = section_mark.section and
					   get_field_from_line(to_string(line),2) = options_keyword_bridges then
						section_bridges_entered := true;

						write_message (
							file_handle => file_mkoptions_messages,
							identation => 1,
							text => "bridges ...",
							console => true);

					end if;
				else -- we are inside section bridges

					-- search for footer of section bridges
					if get_field_from_line(to_string(line),1) = section_mark.endsection then -- we are leaving section bridges
						section_bridges_entered := false; 

						case bridge_is_array is
							when false =>
								append(list_of_bridges, (bridge_preliminary with is_array => false));
							when true =>
								append(list_of_bridges, (bridge_preliminary with 
															is_array => true, 
															list_of_bridges => list_of_bridges_within_array_preliminary));
						end case;
						
					else
						-- read bridges like:
						--  R4
						--  R11*
						--  RN303 array 1-2 3-4 5-6 7-8

						-- read name of bridge and check if name contains wildcards
						bridge_preliminary.name := to_bounded_string(get_field_from_line(to_string(line),1));

						-- report bridge in logfile
						write_message (
							file_handle => file_mkoptions_messages,
							identation => 2,
							text => to_string(bridge_preliminary.name),
							lf => false,
							console => false);

						bridge_preliminary.wildcards := has_wildcards(bridge_preliminary.name);						
						if bridge_preliminary.wildcards then
							write_message (
								file_handle => file_mkoptions_messages,
								identation => 1,
								text => "has wildcards",
								lf => false,
								console => false);
						end if;
						
						-- Field #2 may indicate that this is an array.
						if field_count > 1 then
							if get_field_from_line(to_string(line),2) = options_keyword_array then
								bridge_is_array := true;

								write_message (
									file_handle => file_mkoptions_messages,
									identation => 1,
									text => "is array",
									console => false);

								-- build a preliminary list of bridges from fields after "array"
								if field_count > 2 then
									list_of_bridges_within_array_preliminary := read_bridges_of_array(
										line 			=> to_string(line),
										field_count 	=> field_count,
										line_counter	=> line_counter);
								else
									-- put a final linebreak at end of line in logfile
-- 									new_line (file_mkoptions_messages);
									
									write_message (
										file_handle => file_mkoptions_messages,
										text => message_error & "in line" & positive'image(line_counter) & ": " 
											& "Bridges within array expected ! Example: RN4 array 1-8 2-7 3-6 4-5",
										console => true);
									raise constraint_error;
								end if;
								
							else
								-- put a final linebreak at end of line in logfile
								new_line (file_mkoptions_messages);
								
								write_message (
									file_handle => file_mkoptions_messages,
									text => message_error & "in line" & positive'image(line_counter) & ": " 
										& "Keyword '" & options_keyword_array & "' expected after device name ! "
										& "Example: RN4 array 1-8 2-7 3-6 4-5",
									console => true);
								raise constraint_error;
							end if;
						else 
							-- It is not an array of bridges.
							bridge_is_array := false;

-- 							-- Purge preliminary list of bridges within array for next spin.							
-- 							if length(list_of_bridges_within_array_preliminary) > 0 then
-- 								delete(list_of_bridges_within_array_preliminary,1,length(list_of_bridges_within_array_preliminary));
-- 							end if;

						end if;

						-- put a final linebreak at end of line in logfile
						new_line (file_mkoptions_messages);

					end if;
				end if;

			end if;
		end loop;	
		close(file_mkoptions);
	end read_mkoptions_configuration;
		
	procedure write_statistics is
	begin
-- 		conpair_ct := count_connector_pairs;
-- 		put ("-- connector pairs  :" & Natural'Image(conpair_ct)); new_line;	
-- 
-- 		bridge_ct := count_bridges;
-- 		--put ("-- bridges         :" & Natural'Image(bridge_ct)); new_line;	
-- 
-- 		net_ct := count_nets;
-- 		put ("-- net count total  :" & Natural'Image(net_ct) & " (incl. non-bs nets)"); new_line;
-- 		put ("--                    NOTE: Non-bs nets are commented and shown as supplementary information only."); new_line; 
-- 		put ("--                          Don't waste your time editing their net classes !"); new_line;
-- 
-- 		new_line(standard_output);		
-- 		if make_netlist
-- 			(
-- 			con_pair_list_in => make_conpair_list,
-- 			bridge_list_in => make_bridge_list
-- 			)
-- 		then null; end if;
		null;
	end write_statistics;
	
-------- MAIN PROGRAM ------------------------------------------------------------------------------------

begin
	action := mkoptions;
	
	new_line;
	put_line(to_upper(name_module_mkoptions) & " version " & version);
	put_line("===============================");
	prog_position	:= 10;
 	name_file_database := to_bounded_string(argument(1));
 	put_line(text_identifier_database & "       : " & to_string(name_file_database));

	prog_position	:= 20;
	name_file_options:= to_bounded_string(argument(2));
	put_line ("options file   : " & to_string(name_file_options));
          
	prog_position	:= 25;
    read_database;
    
	-- recreate an empty tmp directory
	prog_position	:= 30;
	create_temp_directory;
-- 	prog_position	:= 40;
-- 	create_bak_directory;

	-- create message/log file
	prog_position	:= 40;
 	write_log_header(version);

	-- write name of database in logfile
	put_line(file_mkoptions_messages, text_identifier_database 
		 & row_separator_0
		 & to_string(name_file_database));

	-- write name of options file in logfile
	put_line(file_mkoptions_messages, "options file"
		 & row_separator_0
		 & to_string(name_file_options));
	
	
	-- if opt file already exists, backup old opt file
-- 	if exists(universal_string_type.to_string(name_file_options)) then
-- 		put_line("WARNING : Target options file '" & universal_string_type.to_string(name_file_options) & "' already exists.");
-- 		put_line("          If you choose to overwrite it, a backup will be created in directory 'bak'."); new_line;
-- 		put     ("          Do you really want to overwrite existing options file '" & universal_string_type.to_string(name_file_options) & "' ? (y/n) "); get(key);
-- 		if key = "y" then       
-- 			-- backup old options file
-- 			copy_file(universal_string_type.to_string(name_file_options),"bak/" & universal_string_type.to_string(name_file_options));		
-- 		else		
--             -- user abort
-- 			prog_position := 100; 
-- 			raise constraint_error;
-- 		end if;
-- 	end if;

	-- create options file
	prog_position	:= 50;
	write_message (
		file_handle => file_mkoptions_messages,
-- 		identation => 1,
		text => "creating options file " & to_string(name_file_options) & "...",
		console => false);
	create( file => file_options, mode => out_file, name => type_name_file_options.to_string(name_file_options));

	-- create routing file
	prog_position	:= 60;
    name_file_routing := to_bounded_string (compose ( 
						name => base_name(type_name_database.to_string(name_file_database)),
						extension => file_extension_routing));
	write_message (
		file_handle => file_mkoptions_messages,
-- 		identation => 1,
		text => "creating routing table " & to_string(name_file_routing) & "...",
		console => false);
	create( file => file_routing, mode => out_file, name => to_string(name_file_routing));

	prog_position	:= 70;
	write_routing_file_header;

	prog_position	:= 80;
	write_options_file_header;
	

	-- check if mkoptions.conf exists
	prog_position	:= 90;	
	if not exists (name_file_mkoptions_conf) then

		write_message (
			file_handle => file_mkoptions_messages,
	-- 		identation => 1,
			text => message_error & "No configuration file '" & name_file_mkoptions_conf & "' found !",
			console => true);
		raise constraint_error;
	end if;
	
	read_mkoptions_configuration;
-- CS:	write_statistics;



	

	close(file_options);

	csv.put_field(file_routing,"-- END OF TABLE");
	close(file_routing);

	write_log_footer;

	exception when event: others =>
		set_exit_status(failure);
		set_output(standard_output);

		write_message (
			file_handle => file_mkoptions_messages,
			text => message_error & " at program position " & natural'image(prog_position),
			console => true);
	
		if is_open(file_options) then
			close(file_options);
		end if;

		case prog_position is
			when 10 =>
				write_message (
					file_handle => file_mkoptions_messages,
					text => message_error & text_identifier_database & " file missing or insufficient access rights !",
					console => true);

				write_message (
					file_handle => file_mkoptions_messages,
					text => "       Provide " & text_identifier_database & " name as argument. Example: mkoptions my_uut.udb",
					console => true);

			when 20 =>
				write_message (
					file_handle => file_mkoptions_messages,
					text => "Options file missing or insufficient access rights !",
					console => true);

				write_message (
					file_handle => file_mkoptions_messages,
					text => "       Provide options file as argument. Example: chkpsn my_uut.udb my_options.opt",
					console => true);

			when others =>
				write_message (
					file_handle => file_mkoptions_messages,
					text => "exception name: " & exception_name(event),
					console => true);

				write_message (
					file_handle => file_mkoptions_messages,
					text => "exception message: " & exception_message(event),
					console => true);
		end case;

		write_log_footer;

			
end mkoptions;
