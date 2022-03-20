import QtQuick 2.0
import Sailfish.Silica 1.0
import "pages"
import "components"

ApplicationWindow
{
    LocationFormatter     { id: locationFormatter }
    Providers             { id: providers         }

    SatelliteBarchartPage { id: barchartPage      }
    SatelliteInfoPage     { id: radarPage         }
    FirstPage             { id: mainPage          }
    
    CoverPage             { id: coverPage         }

    initialPage: mainPage

    cover: coverPage
}
