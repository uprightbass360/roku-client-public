' ********************************************************************
' **  Entry point for the Plex client. Configurable themes etc. haven't been yet.
' **
' ********************************************************************

Sub Main()
	' Development statements
	' RemoveAllServers()
	' AddServer("iMac", "http://192.168.1.3:32400")
    screenFacade = CreateObject("roPosterScreen")
    screenFacade.show()
    'initialize theme attributes like titles, logos and overhang color
    initTheme()

    showUpgradeMessage()

    'prepare the screen for display and get ready to begin
    screen=preShowHomeScreen("", "")
    if screen=invalid then
        print "unexpected error in preShowHomeScreen"
        return
    end if
    servers = PlexMediaServers()
    showHomeScreen(screen, servers)
End Sub


'*************************************************************
'** Set the configurable theme attributes for the application
'** 
'** Configure the custom overhang and Logo attributes
'** Theme attributes affect the branding of the application
'** and are artwork, colors and offsets specific to the app
'*************************************************************

Sub initTheme()

    app = CreateObject("roAppManager")
    theme = CreateObject("roAssociativeArray")

    theme.OverhangOffsetSD_X = "72"
    theme.OverhangOffsetSD_Y = "31"
    theme.OverhangSliceSD = "pkg:/images/Background_SD.jpg"
    theme.OverhangLogoSD  = "pkg:/images/logo_final_SD.png"

    theme.OverhangOffsetHD_X = "125"
    theme.OverhangOffsetHD_Y = "35"
    theme.OverhangSliceHD = "pkg:/images/Background_HD.jpg"
    theme.OverhangLogoHD  = "pkg:/images/logo_final_HD.png"

    app.SetTheme(theme)

End Sub

Sub showUpgradeMessage()
    device = CreateObject("roDeviceInfo")
    version = device.GetVersion()
    major = Mid(version, 3, 1)
    minor = Mid(version, 5, 2)

    ' This shouldn't really exist in the wild...
    if major.toint() <= 3 AND minor.toint() < 1 then
        print "Can't upgrade, firmware 3.1 required"
        return
    end if

    port = CreateObject("roMessagePort")
    screen = CreateObject("roParagraphScreen")
    screen.SetMessagePort(port)
    screen.AddHeaderText("Plex for Roku in the Channel Store!")
    screen.AddParagraph("We're very excited to announce that Plex for Roku is now out of beta and available in the Channel Store (still free).")
    screen.AddParagraph("The new release has oodles of improvements, including myPlex support, support for audio and photo sections, direct play, and a revamped UI.")
    screen.AddParagraph("Do you want to install the new version now?")
    screen.AddButton(1, "Yes, please!")
    screen.AddButton(2, "No thanks")
    screen.Show()

    while true
        msg = wait(0, port)
        if type(msg) = "roParagraphScreenEvent"
            if msg.isScreenClosed() then
                exit while
            else if msg.isButtonPressed() then
                if msg.GetIndex() = 1 then
                    ' Really, no localhost support?
                    addrs = device.GetIPAddrs()
                    addrs.Reset()
                    if addrs.IsNext() then
                        addr = addrs[addrs.Next()]
                        http = NewHttp("http://" + addr + ":8060/launch/11?contentID=13535")
                        http.PostFromStringWithTimeout("", 60)
                    end if
                else
                    screen.Close()
                end if
            end if
        end if
    end while
End Sub

