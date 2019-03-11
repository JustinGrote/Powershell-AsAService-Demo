@{
    PSDependOptions = @{
        Target = 'CurrentUser'
    }
    
    AWSLambdaPSCore = 'latest'

    Pester = 'latest'
    
    'terraform' = @{
        DependencyType = 'Npm'
        Version = 'latest'
        Target = 'Global'
    }

    'serverless' = @{
        DependencyType = 'Npm'
        Version = 'latest'
        Target = 'Global'
    }

    
}