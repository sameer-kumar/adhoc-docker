# nano-python
This is a docker build for Windows Nano server with Python 3.6 baked.

Requirements:

1. Install 3.6.8 Python on your machine with options as:

    a. Chose custom installation
    
    b. Add to PATH
    
    c. Install for all users
    
    d. Install location: C:\Python\Python36
    
    e. Remove max length limitation
2. Create a dir C:\IM-docker
3. Copy Python folder from C:\ to C:\IM-docker
4. 	Add custom root cert to python local environment (if applicable to your environment)

	a. [Reference](https://stackoverflow.com/questions/39356413/how-to-add-a-custom-ca-root-certificate-to-the-ca-store-used-by-pip-in-windows)

    b. Create C:\IM-docker\certs folder

	c. Execute the PowerShell - ExtractCertificatesFromStore.ps1 locally on your machine to generate ca-bundle.pem file.

    d. Copy this CA bundle to C:\IM-docker\certs folder.

    e. Configure pip to use CA cert bundle created above.

	Create pip.ini file with below contents in C:\IM-docker\Python\Python36
		
		
        [global]
		cert = C:\certs\ca-bundle.pem
        
    
