all: synthesize translate map placeandroute
	@echo Everything is done! log files are in log/
synthesize:
	xst -ifn "./scripts/SimCore.xst" -ofn "./log/xst.log"

translate: synthesize
	ngdbuild -intstyle ise -dd _ngo -nt timestamp -uc virtex5.ucf -p xc5vlx110t-ff1136-2 SimCore.ngc SimCore.ngd > ./log/ngdbuild.log

map: translate
	map -intstyle ise -p xc5vlx110t-ff1136-2 -w -logic_opt off -ol high -t 1 -register_duplication off -global_opt off -mt off -cm area -ir off -pr off -lc off -power off -o SimCore_map.ncd SimCore.ngd SimCore.pcf > ./log/map.log

placeandroute: map
	par -w -intstyle ise -ol high -mt off SimCore_map.ncd SimCore.ncd SimCore.pcf > ./log/par.log

clean:
	ls | grep -v -E "\w*\.vhd|SimCore.ncd|\.gitignore|\.git|\.xise|RS232.ngc|\.ucf|\.prj" | grep -E "\w*\.\w*" | xargs rm -v -f
	ls | grep -v -E "\w*\.vhd|SimCore.ncd|\.gitignore|\.git|\.xise|RS232.ngc|\.ucf|\.prj|log|scripts|src|Makefile" | xargs rm -v -f -r

clean_log:
	rm -f -v ./log/*.log

