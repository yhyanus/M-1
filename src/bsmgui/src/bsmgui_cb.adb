with ada.strings; 				use ada.strings;
with ada.strings.fixed; 		use ada.strings.fixed;
with ada.text_io; 				use ada.text_io;
with ada.characters.handling; 	use ada.characters.handling;
with ada.directories;			use ada.directories;
with gnat.os_lib;   			use gnat.os_lib;
with ada.environment_variables;	--use ada.environment_variables;
with gtk.main;
with m1_internal; 				use m1_internal;
with m1_files_and_directories; 	use m1_files_and_directories;

package body bsmgui_cb is

	procedure terminate_main (self : access gtk_widget_record'class) is
	begin
		put_line ("terminated");
		--destroy (self);
		gtk.main.main_quit;
	end terminate_main;



	procedure set_project (self : access gtk_file_chooser_button_record'class) is
	begin
		name_project := universal_string_type.to_bounded_string(gtk.file_chooser_button.get_current_folder(self));

			put_line("set project:" & universal_string_type.to_string(name_project));

			if chooser_set_test.set_current_folder(universal_string_type.to_string(name_project)) then 
				put_line("project preset for test: " & universal_string_type.to_string(name_project));
			end if;
			if chooser_set_script.set_current_folder(universal_string_type.to_string(name_project)) then 
				put_line("project preset for script: " & universal_string_type.to_string(name_project));
			end if;

			set_sensitive (chooser_set_test, true);
			set_sensitive (chooser_set_script, true);

	end set_project;


	procedure set_script (self : access gtk_file_chooser_button_record'class) is
	begin
		set_sensitive (button_start_stop_script, true);
		name_script := universal_string_type.to_bounded_string(gtk.file_chooser_button.get_filename(self));
		put_line("set script: " & universal_string_type.to_string(name_script));
	end set_script;


	procedure set_test (self : access gtk_file_chooser_button_record'class) is
	begin
		set_sensitive (button_start_stop_test, true);
		name_test := universal_string_type.to_bounded_string(gtk.file_chooser_button.get_filename(self));
		put_line("set test: " & universal_string_type.to_string(name_test));
	end set_test;


	procedure start_stop_test (self : access gtk_button_record'class) is
		result 	: natural := 0;
		dead	: boolean;
		success	: boolean := false;
 		function system( cmd : string ) return integer;
 		pragma Import( C, system );

	begin
		set_sensitive (chooser_set_uut, false);
		set_sensitive (chooser_set_script, false);
		set_sensitive (chooser_set_test, false);

		set_directory(universal_string_type.to_string(name_project));

		case status_test is
			when stopped =>
				--set_sensitive (button_start_stop_script, false);
				set_label(button_start_stop_test,"STOP");
				put_line ("start test: " & universal_string_type.to_string(name_test));

				set(img_status, 
					universal_string_type.to_string(name_directory_home) & name_directory_separator & -- /home/user/
					compose
						(
						containing_directory => name_directory_configuration_images,
						name => name_file_image_run,
						extension => file_extension_png
						)
					);
				
				while gtk.main.events_pending loop dead := gtk.main.main_iteration; end loop;

				--put_line(universal_string_type.to_string(name_directory_bin) & name_directory_separator & name_module_cli);
				pid := non_blocking_spawn 
					(  
					program_name           => universal_string_type.to_string(name_directory_bin) & name_directory_separator & name_module_cli,
					args                   => 	(
												1=> new string'(to_lower(type_action'image(run))),
												2=> new string'(simple_name(universal_string_type.to_string(name_test))),
		 										3=> new string'("off"),
		 										4=> new string'("&")
												)
		-- 			output_file_descriptor => standout,
		-- 			return_code            => result
					);
				if pid = invalid_pid then
					put_line(message_error & " test spawning failed");
				else
					put_line("test started with proc id: " & integer'image(pid_to_integer(pid)));
					status_test := running;
				end if;

--				while gtk.main.events_pending loop dead := gtk.main.main_iteration; end loop;
				wait_process(pid,success);
				if success then
					put_line("test finished");
				end if;


-- 				while result = 0
-- 					loop
-- 						result := system( "sleep 0.5; ps -A | grep bsmcl" & ASCII.NUL );
-- 						while gtk.main.events_pending loop dead := gtk.main.main_iteration; end loop;
-- 					end loop;

-- 				for i in 1..10 loop
-- 					delay 1.0;
-- 					while gtk.main.events_pending loop dead := gtk.main.main_iteration; end loop;
-- 					spawn 
-- 						(  
-- 						program_name           => "/bin/ps",
-- 						args                   => 	(
-- 													1=> new string'("-p"),
-- 													2=> new string'(trim(integer'image(pid_to_integer(pid)),left))
-- 													),
-- 						output_file_descriptor => standout,
-- 						return_code            => result
-- 						);
-- 					if result = 0 then
-- 						put_line("still running...");
-- 					else
-- 						put_line("ended");
-- 						exit;
-- 					end if;
-- 				end loop;


				put_line("TEST END");








			when running =>
				put_line ("aborting test: " & universal_string_type.to_string(name_test));
				put_line ("with proc id :" & integer'image(pid_to_integer(pid)));
				spawn 
					(  
					program_name           => "/bin/kill",
					args                   => 	(
												1=> new string'(integer'image(pid_to_integer(pid)))
												),
		 			output_file_descriptor => standout,
		 			return_code            => result
					);
				if result = 0 then
					put_line("kill successful");
				else
					put_line("kill failed");
				end if;

				status_test := stopped;
				set_label(button_start_stop_test,"START");
		end case;



-- 		if result = 0 then
-- 			put_line(passed);
-- 			set(img_status, 
-- 				universal_string_type.to_string(name_directory_home) & name_directory_separator & -- /home/user/
-- 				compose
-- 					(
-- 					containing_directory => name_directory_configuration_images,
-- 					name => name_file_image_pass,
-- 					extension => file_extension_png
-- 					)
-- 				);
-- 
-- 		else
-- 			put_line(failed);
-- 			set(img_status, 
-- 				universal_string_type.to_string(name_directory_home) & name_directory_separator & -- /home/user/
-- 				compose
-- 					(
-- 					containing_directory => name_directory_configuration_images,
-- 					name => name_file_image_fail,
-- 					extension => file_extension_png
-- 					)
-- 				);
-- 
-- 		end if;

		set_sensitive (chooser_set_uut, true);
		set_sensitive (chooser_set_script, true);
		set_sensitive (chooser_set_test, true);
		set_sensitive (button_start_stop_script, true);
	end start_stop_test;


	procedure start_stop_script (self : access gtk_button_record'class) is
		result 	: natural;
		dead	: boolean;
	begin
		set_sensitive (chooser_set_uut, false);
		set_sensitive (chooser_set_script, false);
		set_sensitive (chooser_set_test, false);
		set_sensitive (button_start_stop_test, false);
		put_line ("start_stop_script: " & universal_string_type.to_string(name_script));
		set_directory(universal_string_type.to_string(name_project));

		put_line(m1_internal.running);
		set(img_status, 
			universal_string_type.to_string(name_directory_home) & name_directory_separator & -- /home/user/
			compose
				(
				containing_directory => name_directory_configuration_images,
				name => name_file_image_run,
				extension => file_extension_png
				)
			);
		while gtk.main.events_pending loop dead := gtk.main.main_iteration; end loop;

		spawn 
			(  
			program_name           => universal_string_type.to_string(name_script),
			args                   => 	(
										1=> new string'("")
										),
			output_file_descriptor => standout,
			return_code            => result
			);


		if result = 0 then
			put_line(passed);
			set(img_status, 
				universal_string_type.to_string(name_directory_home) & name_directory_separator & -- /home/user/
				compose
					(
					containing_directory => name_directory_configuration_images,
					name => name_file_image_pass,
					extension => file_extension_png
					)
				);

		else
			put_line(failed);
			set(img_status, 
				universal_string_type.to_string(name_directory_home) & name_directory_separator & -- /home/user/
				compose
					(
					containing_directory => name_directory_configuration_images,
					name => name_file_image_fail,
					extension => file_extension_png
					)
				);

		end if;

		set_sensitive (chooser_set_uut, true);
		set_sensitive (chooser_set_script, true);
		set_sensitive (chooser_set_test, true);
		set_sensitive (button_start_stop_test, true);
	end start_stop_script;


	procedure abort_shutdown (self : access gtk_button_record'class) is
		result 	: natural;
--		dead	: boolean;
	begin
		set_sensitive (chooser_set_uut, false);
		set_sensitive (chooser_set_script, false);
		set_sensitive (chooser_set_test, false);
		set_sensitive (button_start_stop_test, false);
		--set_directory(universal_string_type.to_string(name_project));

		put_line(aborting);
-- CS: image for abort ?
-- 		set(img_status, 
-- 			universal_string_type.to_string(name_directory_home) & name_directory_separator & -- /home/user/
-- 			compose
-- 				(
-- 				containing_directory => name_directory_configuration_images,
-- 				name => name_file_image_run,
-- 				extension => file_extension_png
-- 				)
-- 			);
-- 		while gtk.main.events_pending loop dead := gtk.main.main_iteration; end loop;

		spawn 
			(  
			program_name           => universal_string_type.to_string(name_directory_bin) & name_directory_separator & name_module_cli,
			args                   => 	(
										1=> new string'(to_lower(type_action'image(off)))
										),
			output_file_descriptor => standout,
			return_code            => result
			);

		if result = 0 then
			put_line(successful);
			set(img_status, 
				universal_string_type.to_string(name_directory_home) & name_directory_separator & -- /home/user/
				compose
					(
					containing_directory => name_directory_configuration_images,
					name => name_file_image_aborted,
					extension => file_extension_png
					)
				);

		else
			put_line(failed);
			set(img_status, 
				universal_string_type.to_string(name_directory_home) & name_directory_separator & -- /home/user/
				compose
					(
					containing_directory => name_directory_configuration_images,
					name => name_file_image_abort_failed,
					extension => file_extension_png
					)
				);

		end if;

		set_sensitive (chooser_set_uut, true);
		set_sensitive (chooser_set_script, true);
		set_sensitive (chooser_set_test, true);
		set_sensitive (button_start_stop_test, true);
	end abort_shutdown;

end bsmgui_cb;
