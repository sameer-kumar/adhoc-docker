#escape=`
# https://github.com/chocolatey/choco/issues/1371
# https://chocolatey.org/docs/installation#completely-offline-install
# FROM mcr.microsoft.com/windows/servercore:ltsc2019

FROM mcr.microsoft.com/windows/servercore:1903

#ENV chocolateyUseWindowsCompression='false' 

ADD scripts/installChocoLocal.ps1 /installChocoLocal.ps1
COPY jreinstall.cfg /jreinstall.cfg
COPY jre-8u221-windows-i586.exe /jre-8u221-windows-i586.exe
COPY chocoPkgs /choco-packages

RUN mkdir app-data
VOLUME c:/app-data

# Install chocolatey
RUN powershell .\installChocoLocal.ps1 -ChocolateyPackageFilePath '.\choco-packages\chocolatey.0.10.15.nupkg' -Wait; Remove-Item c:\installChocoLocal.ps1; 

# Install JRE
RUN powershell Start-Process -FilePath .\jre-8u221-windows-i586.exe -ArgumentList 'INSTALLCFG=c:\jreinstall.cfg' -Wait
# Start-Process -FilePath .\jre-8u221-windows-i586.exe -ArgumentList 'INSTALLCFG=c:\app-data\jreinstall.cfg' -Wait

# Install choco pkg of git
RUN powershell cinst .\choco-packages\git.2.22.0.nupkg -y
RUN powershell refreshenv

# Install pkg of java runtime
RUN powershell cinst .\choco-packages\javaruntime.8.0.191.nupkg -y --ignore-dependencies
RUN powershell refreshenv

# Install pkg of git-tf
RUN powershell cinst .\choco-packages\Git-TF.2.0.3.20131219.nupkg -y --ignore-dependencies
RUN powershell refreshenv

#RUN setx path "%path%;C:\java\jre\bin"
#RUN setx /M PATH $($Env:PATH + ';C:\java\jre\bin') 

#SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"

# Remove installers
RUN powershell Remove-Item c:\choco-packages -Recurse -Force; Remove-Item c:\jre-8u221-windows-i586.exe -Force;

CMD [ "powershell" ]

#  docker run --name gtf -it --rm -v c:\temp\mapvol:c:\app-data gittfs:v1        