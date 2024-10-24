BeforeAll {

    $ProjectDirectory = Split-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -Parent
    $PublicPath = Join-Path $ProjectDirectory "/PsFmcsa/Public/"
  
    $FixturesDirectory = Join-Path $ProjectDirectory "/Tests/Fixtures/"

    $SUT = (Split-Path -Leaf $PSCommandPath) -replace '\.Tests\.', '.'
    . (Join-Path $PublicPath $SUT)
  
  }
  
  Describe 'Find-FmcsaExaminer' {
  
    Context "Parameter validation" {
  
        BeforeAll {
            $Command = Get-Command 'Find-FmcsaExaminer'
        } 
  
        $Parameters = @(
            @{ParameterName='RegistryID'; Type='string'; Mandatory=$false}
            @{ParameterName='FirstName'; Type='string'; Mandatory=$false}
            @{ParameterName='LastName'; Type='string'; Mandatory=$false}
            @{ParameterName='BusinessName'; Type='string'; Mandatory=$false}
            @{ParameterName='Distance'; Type='int'; Mandatory=$false}
            @{ParameterName='Units'; Type='string'; Mandatory=$false}
        )
  
        Context 'Data type' {        
            It "<ParameterName> is a <Type>" -TestCases $Parameters {
                param ($ParameterName, $Type)
                $Command | Should -HaveParameter $ParameterName -Type $Type
            }
        }
  
        Context "Mandatory" {
            it "<ParameterName> Mandatory is <Mandatory>" -TestCases $Parameters {
                param($ParameterName, $Mandatory)
                
                if ($Mandatory) { $Command | Should -HaveParameter $ParameterName -Mandatory }
                else { $Command | Should -HaveParameter $ParameterName -Not -Mandatory }
            }
        }
  
    } 

    Context "Request" {

        BeforeEach {
            Mock Invoke-WebRequest

            $JWT = (New-Guid).Guid

            Find-FmcsaExaminer -JWT $JWT
        }

        It 'uses the correct Headers' {
            Assert-MockCalled -CommandName Invoke-WebRequest -ParameterFilter {
                $Headers.Accept -eq'application/json' -and
                $Headers.'cl_jw_token' -eq $JWT
            }
        }

        It 'uses the correct Uri' {
            Assert-MockCalled -CommandName Invoke-WebRequest -ParameterFilter {
                $Uri -like "https://nrcme-prod-api.natss-aws.us/prod/search-medical-examiners/map*"
            }
        }
  
        It 'uses the correct Method' {
            Assert-MockCalled -CommandName Invoke-WebRequest -ParameterFilter {
                $Method -eq 'Get'
            }
        }
  
        Context "when the RegistryID parameter is supplied" {

            BeforeEach {
                $RegistryID = '0123456789'
                Find-FmcsaExaminer -JWT $JWT -RegistryID $RegistryID
            }
            It 'uses the correct Uri' {
                Assert-MockCalled -CommandName Invoke-WebRequest -ParameterFilter {
                    $Uri -like "*nationalRegNumber=$RegistryID*"
                }
            }
    
        }
    }

    Context "Response" {
        BeforeEach {
            Mock Invoke-WebRequest {
                $Fixture = 'Find-FmcsaExaminer.200.json'
                $Content = Get-Content (Join-Path $FixturesDirectory $Fixture) -Raw

                $Response = New-MockObject -Type  Microsoft.PowerShell.Commands.BasicHtmlWebResponseObject
                $Response | Add-Member -Type NoteProperty -Name 'Content' -Value $Content -Force
                $Response
            }
            
            $Actual = Find-FmcsaExaminer -JWT (New-Guid).Guid
        }

        it 'returns an array of examiners' {
            $Actual.Length | Should -Be 1
        }

    }
}