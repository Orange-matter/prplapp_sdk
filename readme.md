# prpl Applications almost SDK

This project provide a docker environment with useful libraries and tools helps to build, debug and test applications for prpl containers. The Docker images inclues :

 - Ambiorix tools, libs and samples and python binding: https://gitlab.com/prpl-foundation/components/ambiorix/ambiorix
 - uci, ubus and procd tools and libs comming from OpenWrt : https://clockworkbird9.wordpress.com/2020/02/16/install-libubox-and-ubus-on-ubuntu/


Disclaimer : 
- An "official" Ambiorix SDK  is available here : https://gitlab.com/prpl-foundation/components/ambiorix/tutorials/getting-started. The goal of this project is not to replace it, but to provide one based on Ubuntu, built dynamically on x64 and amd64 and with openwrt libraries and tools and configurations.

- The development environment provided is not link to LCM SDK. The goal is not to build container image for prplOS, but to help to develop application for container images using Ambiorix agent.

## Principles
The SDk is based on the parent Docker image dynamically built and described in Dockerfile. Feel free to adapt it according to your needs.

The SDK comes with a script to create the parent Docker image and create Docker containers based on this image for development projects.

Creating a development container takes as an argument a directory where your development project is located.

When creating the container, for useful purposes, a user with the same name and UID:GID used to run the script is created in the container. But by default the script logs in as root.

After the development container is created and running, you can use Visual Studio Code IDE (https://code.visualstudio.com) to connect to the SDK container for building, debugging, and testing. A practical guide is described in this documentation.

## Usage
To manage SDK image and containers you can use the script *prpl-appsdk.sh*, options are :
- **build** : build the parent image used for development container
- **list** : list all development container
- **start < development directory >** : start a development container (build the parent image if they not exist) linked to  development directory given in parameters
    - By default you login as root (enter su current user to login as courent usez)
- **stop** / **delete**  : stop or delete a development container linked to  development directory
    - the developpement directory is not deleted, in case of delete option, only the development container is deleted. 

# How to
This section describes the use of the SDK according to an example included in the parent image.

This tutorial used Visual Studio Code IDE (https://code.visualstudio.com)

Disclaimer : This is not a tutorial to develelopement Ambiorix plugin, and not a tutorial how using LCM SDK. For that, you can read for example :
-  https://prplfoundationcloud.atlassian.net/wiki/spaces/LCM/pages/194936927/LCM+SDK+-+Introduction+and+howto
- https://gitlab.com/soft.at.home/usp/applications/usp-endpoint/
- https://gitlab.com/soft.at.home/usp/applications/uspagent

## HOST IDE Configuration
To woks intall the fellowing extenssion to your Visual Studio Code IDE. :
- Remote Development : https://code.visualstudio.com/docs/remote/remote-overview



## Create developpement container
In the root directory where the SDK is installed, create a test directory and start a development container on it.

```
bigiot:~/prpl/prplapp_sdk$ mkdir test
bigiot:~/prpl/prplapp_sdk$ ./prpl-appsdk.sh start test
-> Start SDK for test
INFO: Group doesn't exist; creating...
Adding group `matter' (GID 1001) ...
Done.
INFO: User doesn't exist; creating...
Adding system user `matter' (UID 1001) ...
Adding new user `matter' (UID 1001) with group `matter' ...
Creating home directory `/home/matter' ...
INFO: Set privilege for  matter...
INFO: Running prpl Application SDK as matter:matter (1001:1001)
root@ed34f854b080:/sdkworkdir/workspace# 
```
## Connect the IDE to the development container

At the bottom right of your IDE, clic on remote extenssion : 

![remote extenssion](/images/remote-ext.png)

Then select "attach to running container" :
![attach to running container](/images/attach-container.png)

and select the prplappsdk_test container :
![select container](/images/select-container.png  )


### Install IDE extenssion on container
To woks intall the fellowing extenssion to your Visual Studio Code IDE. :
- C/C++ for Visual Studio Code : https://code.visualstudio.com/docs/languages/cpp
- Makefile Tools https://marketplace.visualstudio.com/items?itemName=ms-vscode.makefile-tools
- Python & Python Environment Manager : https://code.visualstudio.com/docs/languages/python, https://marketplace.visualstudio.com/items?itemName=donjayamanne.python-environment-manager if you plan to develop in python


## Open the sample project
Then open the workspace /sdkwordir where are Ambiorix samples in the directory examles, and go to the diectorty : *examples/datamodel/cpu-info/*

A complete description of the sample can be found here :  https://gitlab.com/prpl-foundation/components/ambiorix/examples/datamodel/cpu-info

### build the sample
In a terminal on the development container, you can make the project using *make clean all*.
```
root@3c97496cf67f:/sdkworkdir/examples/datamodel/cpu-info# make clean all
make -C src clean
make[1]: Entering directory '/sdkworkdir/examples/datamodel/cpu-info/src'
rm -rf ../output/
make[1]: Leaving directory '/sdkworkdir/examples/datamodel/cpu-info/src'
make -C test clean
make[1]: Entering directory '/sdkworkdir/examples/datamodel/cpu-info/test'
rm -rf ../output/x86_64-linux-gnu/coverage
rm -rf ../output/x86_64-linux-gnu/coverage/report
find .. -name "run_test" -delete
make[1]: Leaving directory '/sdkworkdir/examples/datamodel/cpu-info/test'
make -C src all
make[1]: Entering directory '/sdkworkdir/examples/datamodel/cpu-info/src'
/usr/bin/mkdir -p ../output/x86_64-linux-gnu/object/
cc -Werror -Wall -Wextra -Wformat=2 -Wshadow -Wwrite-strings -Wredundant-decls -Wmissing-include-dirs -Wpedantic -Wmissing-declarations -Wno-attributes -Wno-format-nonliteral -fPIC -g3 -I ../include_priv -Wstrict-prototypes -Wold-style-definition -Wnested-externs -std=c11 -c -o ../output/x86_64-linux-gnu/object/cpu_info.o cpu_info.c
.....
cc -Wl,-soname,cpu_info.so -o ../output/x86_64-linux-gnu/object/cpu_info.so ../output/x86_64-linux-gnu/object/cpu_info.o ../output/x86_64-linux-gnu/object/cpu_main.o ../output/x86_64-linux-gnu/object/cpu_stats.o ../output/x86_64-linux-gnu/object/dm_cpu_actions.o ../output/x86_64-linux-gnu/object/dm_cpu_mngt.o ../output/x86_64-linux-gnu/object/dm_cpu_mon_actions.o ../output/x86_64-linux-gnu/object/dm_events.o ../output/x86_64-linux-gnu/object/dm_usage_actions.o -shared -fPIC -lamxc -lamxp -lamxd -lamxo
make[1]: Leaving directory '/sdkworkdir/examples/datamodel/cpu-info/src'
root@3c97496cf67f:/sdkworkdir/examples/datamodel/cpu-info# 

```

To enable deguging, you have to add "-g -ggdb" options to the  CFLAGS of the compiler in the Makefile in the directorty */sdkworkdir/examples/datamodel/cpu-info/src/makefile* 
```
# compilation and linking flags
CFLAGS += -g -ggdb \
		  -Werror -Wall -Wextra \
          -Wformat=2 -Wshadow \
          -Wwrite-strings -Wredundant-decls -Wmissing-include-dirs \
		  -Wpedantic -Wmissing-declarations -Wno-attributes \
		  -Wno-format-nonliteral \
		  -fPIC -g3 $(addprefix -I ,$(INCDIRS))
```
and build again the sample, using *make clean all*.

Then install the build the development container through *make install*
```
root@3c97496cf67f:/sdkworkdir/examples/datamodel/cpu-info# make install
make -C src all
make[1]: Entering directory '/sdkworkdir/examples/datamodel/cpu-info/src'
make[1]: Nothing to be done for 'all'.
make[1]: Leaving directory '/sdkworkdir/examples/datamodel/cpu-info/src'
/usr/bin/install -d -m 0755 //etc/amx/cpu_info
/usr/bin/install -D -p -m 0644 odl/cpu_info.odl /etc/amx/cpu_info/;  /usr/bin/install -D -p -m 0644 odl/cpu_info_defaults.odl /etc/amx/cpu_info/;  /usr/bin/install -D -p -m 0644 odl/cpu_info_definition.odl /etc/amx/cpu_info/;
/usr/bin/install -D -p -m 0644 output/x86_64-linux-gnu/object/cpu_info.so /usr/lib/amx/cpu_info/cpu_info.so
/usr/bin/install -d -m 0755 /usr/bin
ln -sfr /usr/bin/amxrt /usr/bin/cpu_info
root@3c97496cf67f:/sdkworkdir/examples/datamodel/cpu-info# 
```

### Run, test and debug the sample
#### Run
You can run the sample using *cpu_info* command in a terminal of the development container.

```
root@3c97496cf67f:/sdkworkdir/examples/datamodel/cpu-info# cpu_info 
[IMPORT-DBG] - dlopen - cpu_info.so (0x560474258b00)
[IMPORT-DBG] - symbol _cpu_monitor_cleanup resolved (for cpu_monitor_cleanup) from cpu_info
[IMPORT-DBG] - symbol _read_usage resolved (for read_usage) from cpu_info
[IMPORT-DBG] - symbol _cleanup_usage resolved (for cleanup_usage) from cpu_info
[IMPORT-DBG] - symbol _cpu_read resolved (for cpu_read) from cpu_info
[IMPORT-DBG] - symbol _cpu_list resolved (for cpu_list) from cpu_info
[IMPORT-DBG] - symbol _cpu_describe resolved (for cpu_describe) from cpu_info
[IMPORT-DBG] - symbol _cpu_cleanup resolved (for cpu_cleanup) from cpu_info
[IMPORT-DBG] - symbol _update_timer resolved (for update_timer) from cpu_info
[IMPORT-DBG] - symbol _enable_periodic_inform resolved (for enable_periodic_inform) from cpu_info
[IMPORT-DBG] - symbol _disable_periodic_inform resolved (for disable_periodic_inform) from cpu_info
[IMPORT-DBG] - symbol _cpu_main resolved (for cpu_main) from cpu_info
```

#### Test
Once, *cpu_info* running, you can test the datamodel in a terminal of the development container using *ubus-cli*

```
root@3c97496cf67f:/sdkworkdir/examples/datamodel/cpu-info# ubus-cli 
Copyright (c) 2020 - 2023 SoftAtHome
amxcli version : 0.3.5

!amx silent true

                   _  ___  ____
  _ __  _ __ _ __ | |/ _ \/ ___|
 | '_ \| '__| '_ \| | | | \___ \
 | |_) | |  | |_) | | |_| |___) |
 | .__/|_|  | .__/|_|\___/|____/
 |_|        |_| based on OpenWrt
 -----------------------------------------------------
 ubus - cli
 -----------------------------------------------------

 - ubus: - [ubus-cli] (0)
 > CPUMonitor.?
CPUMonitor.
CPUMonitor.Interval=0
CPUMonitor.PeriodicInform=0
CPUMonitor.Usage=0
CPUMonitor.CPU.1.
CPUMonitor.CPU.1.Family=6
....
 - ubus: - [ubus-cli] (0)
 > 
```
#### Debug
To debug the programme through the IDE, you have to create a launcher. Go to the execute and debug option of the IDE, and select create a launch.json.

An template file is created 
```
{
    "version": "0.2.0",
    "configurations": [
        
        {
            "type": "node",
            "request": "launch",
            "name": "Lancer le programme",
            "skipFiles": [
                "<node_internals>/**"
            ],
            "program": "${file}"
        }
    ]
}
```

Modified the file as follows to run *cpu info* in debug mode.
```
"configurations": [
        {
            "name": "CPU INFO ",
            "type": "cppdbg",
            "request": "launch",
            "program": "/usr/bin/cpu_info",
            "cwd": "${fileDirname}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Activer l'impression en mode Pretty pour gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                },
                {
                    "description": "Définir la version désassemblage sur Intel",
                    "text": "-gdb-set disassembly-flavor intel",
                    "ignoreFailures": true
                }
            ]
```
Then you can add breakpoint to your code, and debug as useful.
![select container](/images/debug.png  )

##### common launcher
As exemple, please find this configuration to launch and debug datamodel by using to */usr/bin/amxrt*  

```
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "amxrt with matter datamodel",
            "type": "cppdbg",
            "request": "launch",
            "program": "/usr/bin/amxrt",
            "args": ["-B", "/usr/bin/mods/amxb/mod-amxb-ubus.so", "-u", "ubus:/var/run/ubus/ubus.sock", "-A", "/home/matter/workspace/dev/uspagent/odl/matter_crtl.odl"],
            "stopAtEntry": false,
            "additionalSOLibSearchPath" : "/usr/lib/amx/matter_crtl/matter_crtl.so",
            "cwd": "${fileDirname}",
            "environment": [],
            "externalConsole": false,
            "MIMode": "gdb",
            "setupCommands": [
                {
                    "description": "Activer l'impression en mode Pretty pour gdb",
                    "text": "-enable-pretty-printing",
                    "ignoreFailures": true
                },
                {
                    "description": "Définir la version désassemblage sur Intel",
                    "text": "-gdb-set disassembly-flavor intel",
                    "ignoreFailures": true
                }
            ]
        }

    ]
}
```




