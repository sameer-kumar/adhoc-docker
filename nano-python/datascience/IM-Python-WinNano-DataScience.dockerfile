# escape=`
# Image build from ..\IM-Python-WinNano.dockerfile
FROM {Registry}/im-python-windows:36-nano 

# Metadata indicating an image maintainer.
LABEL maintainer="sameer-kumar"

# Upgrade PIP
RUN python -m pip install --upgrade pip --user

RUN mkdir c:\Python\AppPackages
# WORKDIR c:\Python\AppPackages


# https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#leverage-build-cache
COPY requirements.txt \requirements.txt
RUN pip install --target="c:\Python\AppPackages" -r \requirements.txt --upgrade --no-cache-dir 

# Set this for module discovery
ENV PYTHONPATH "${PYTHONPATH};c:\Python\AppPackages"

CMD [ "cmd" ]

# docker build --file '.\IM-Python-WinNano-DataScience.dockerfile' --tag im-python-windows-scipy:36-nano-packaged .