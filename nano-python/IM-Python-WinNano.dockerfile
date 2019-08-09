# escape=`

# Indicates that the nanoserver image will be used as the base image
ARG WindowsServerNanoVersion=1809

# Indicates the python version folder
ARG PythonVersionFolder=Python36

FROM mcr.microsoft.com/windows/nanoserver:${WindowsServerNanoVersion} AS BASE

ARG WindowsServerNanoVersion 
ARG PythonVersionFolder

# Metadata indicating an image maintainer.
LABEL maintainer="sameer-kumar"

USER ContainerAdministrator 

# Microsoft removed powershell and other pieces from base nanoserver image.
# SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Copies the python ver files to the server
COPY ./Python c:/Python

# Set the env path 
RUN setx path "%path%;c:\Python;c:\Python\%PythonVersionFolder%;c:\Python\%PythonVersionFolder%\Scripts" /M

# Copies the CA bundle of Trusted Root CA from local user store
COPY ./certs c:/certs

# Copies the PIP configuration to use Trusted Root CA from local user store
ENV PIP_CONFIG_FILE c:/Python/Python36/pip.ini

USER ContainerUser
WORKDIR C:\\_workingDir

# Sets a command or process that will run each time a container is run from the new image.
#CMD [ "python.exe" ]
CMD [ "cmd" ]

# docker build --build-arg=WindowsServerNanoVersion=1903 --tag python-windows:36-nano .
# docker build --build-arg PythonVersionFolder=Python36 --file 'IM-Python-WinNano.dockerfile' --tag im-python-windows:36-nano .