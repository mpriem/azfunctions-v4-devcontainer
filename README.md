# azfunctions-v4-devcontainer
Dev container for Azure Functions v4 (PowerShell)

This is a basic VSCode dev container spec for Azure Functions v4. The OOTB template for a dev container in VSCode only supports PowerShell 7.0.x.
I needed PowerShell 7.2 to be able to get the Microsoft Graph PowerShell modules to work properly due to interoperability issues with an old NewtonSoft.Json version that is part of PowerShell 7.0.x.

I hope with this repo to save someone else some time. Enjoy!

## Instructions
To make use of this Dockerfile, create a new dev container for a Powershell function. Once it is running simply overwrite the Dockerfile in the .devcontainer folder and rebuild the dev container. 

Once you are connected to the dev container after the rebuild, make sure the extensionbundle version in the host.json file is set to  [3.*, 4.0.0). 

```json
{
  "version": "2.0",
  "logging": {
    "applicationInsights": {
      "samplingSettings": {
        "isEnabled": true,
        "excludedTypes": "Request"
      }
    }
  },
  "extensionBundle": {
    "id": "Microsoft.Azure.Functions.ExtensionBundle",
    "version": "[3.*, 4.0.0)"
  },
  "managedDependency": {
    "enabled": true
  }
}
```

Your local functions project should now work with .NET 6.0.4, Azure functions runtime and tools 4.* and PowerShell 7.2.
