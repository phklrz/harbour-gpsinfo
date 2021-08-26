#include "gpsdatasource.h"
#include <QDebug>

GPSSatellite::GPSSatellite(QObject *parent) :
    QObject(parent) {
}

GPSDataSource::GPSDataSource(QObject *parent) :
    QObject(parent), SimulatorTimer(this),
    numberOfUsedSatellites(0),
    numberOfVisibleSatellites(0)
{
    connect(&SimulatorTimer, SIGNAL(timeout()), this, SLOT(SimulatorTimeout()));

    this->sSource = QGeoSatelliteInfoSource::createDefaultSource(this);
    if (this->sSource) {
        qDebug() << "created QGeoSatelliteInfoSource" << this->sSource->sourceName();
        connect(this->sSource, SIGNAL(satellitesInUseUpdated(QList<QGeoSatelliteInfo>)), this, SLOT(satellitesInUseUpdated(QList<QGeoSatelliteInfo>)));
        connect(this->sSource, SIGNAL(satellitesInViewUpdated(QList<QGeoSatelliteInfo>)), this, SLOT(satellitesInViewUpdated(QList<QGeoSatelliteInfo>)));
    } else {
        qDebug() << "cannot create default QGeoSatelliteInfoSource";
    }
    this->pSource = QGeoPositionInfoSource::createDefaultSource(this);
    if (this->pSource) {
        qDebug() << "created QGeoPositionInfoSource" << this->pSource->sourceName();
        connect(this->pSource, SIGNAL(positionUpdated(QGeoPositionInfo)), this, SLOT(positionUpdated(QGeoPositionInfo)));
    } else {
        qDebug() << "cannot create default QGeoPositionInfoSource";
    }
    this->active = false;
}

void GPSDataSource::satellitesInUseUpdated(const QList<QGeoSatelliteInfo> &infos) {
    foreach (QGeoSatelliteInfo info, infos) {
        if (!this->satellites.contains(info.satelliteIdentifier())) {
            GPSSatellite* sat = new GPSSatellite(this);
            sat->setAzimuth(info.attribute(QGeoSatelliteInfo::Azimuth));
            sat->setElevation(info.attribute(QGeoSatelliteInfo::Elevation));
            sat->setIdentifier(info.satelliteIdentifier());
            sat->setSystem(info.satelliteSystem());
            sat->setInUse(true);
            sat->setSignalStrength(info.signalStrength());
            this->satellites[info.satelliteIdentifier()] = sat;
        } else {
            this->satellites[info.satelliteIdentifier()]->setInUse(true);
        }
    }
    emit this->satellitesChanged();
    this->setNumberOfUsedSatellites(infos.size());
}

void GPSDataSource::satellitesInViewUpdated(const QList<QGeoSatelliteInfo> &infos) {
    qDeleteAll(this->satellites);
    this->satellites.clear();
    bool showAll = this->settings.getShowEmptyChannels();
    foreach (QGeoSatelliteInfo info, infos) {
        if(showAll || info.signalStrength() > 0) {
            GPSSatellite* sat = new GPSSatellite(this);
            sat->setAzimuth(info.attribute(QGeoSatelliteInfo::Azimuth));
            sat->setElevation(info.attribute(QGeoSatelliteInfo::Elevation));
            sat->setIdentifier(info.satelliteIdentifier());
            sat->setSystem(info.satelliteSystem());
            sat->setInUse(false);
            sat->setSignalStrength(info.signalStrength());
            this->satellites[info.satelliteIdentifier()] = sat;
        }
    }
    emit this->satellitesChanged();
    this->setNumberOfVisibleSatellites(satellites.size());
}

void GPSDataSource::positionUpdated(QGeoPositionInfo info) {
    this->setMovementDirection(info.attribute(QGeoPositionInfo::Direction));
}

QVariantList GPSDataSource::getSatellites() {
    QList<GPSSatellite*> sats = this->satellites.values();
    QVariantList result;
    foreach (GPSSatellite* sat, sats) {
        result << QVariant::fromValue(sat);
    }
    return result;
}

void GPSDataSource::setActive(bool active) {
    if ( !sSource )
    {
        if ( !this->active && active )
        {
            SimulatorTimer.start(1000);
            this->active = true;
        }
        else if ( this->active && !active )
        {
            SimulatorTimer.stop();
            this->active = false;
        }
        return;
    }
    if (!this->active && active) {
        if (this->sSource) {
            qDebug() << "activating source...";
            this->sSource->startUpdates();
            this->pSource->startUpdates();
            this->active = true;
            emit this->activeChanged(true);
        }
    } else if (this->active && !active) {
        if (this->sSource) {
            qDebug() << "deactivating source...";
            this->sSource->stopUpdates();
            this->pSource->stopUpdates();
            this->active = false;
            qDeleteAll(this->satellites);
            this->satellites.clear();
            emit this->activeChanged(false);
            emit this->satellitesChanged();
        }
    }
}

void GPSDataSource::setUpdateInterval(int updateInterval) {
    if (this->sSource){
        this->sSource->setUpdateInterval(updateInterval);
        this->pSource->setUpdateInterval(updateInterval);
        emit this->updateIntervalChanged(updateInterval);
    }
}

void GPSDataSource::SimulatorTimeout()
{
    QList<QGeoSatelliteInfo> satellites, satellitesInUse;
    QGeoSatelliteInfo satellite;

    satellite.setAttribute(QGeoSatelliteInfo::Azimuth, 60.0);
    satellite.setAttribute(QGeoSatelliteInfo::Elevation, 45.0);
    satellite.setSatelliteIdentifier(8);
    satellite.setSatelliteSystem(QGeoSatelliteInfo::GPS);
    satellite.setSignalStrength(40);
    satellites.append(satellite);
    satellitesInUse.append(satellite);

    satellite.setAttribute(QGeoSatelliteInfo::Azimuth, 100.0);
    satellite.setAttribute(QGeoSatelliteInfo::Elevation, 40.0);
    satellite.setSatelliteIdentifier(22);
    satellite.setSatelliteSystem(QGeoSatelliteInfo::GLONASS);
    satellite.setSignalStrength(35);
    satellites.append(satellite);
    satellitesInUse.append(satellite);

    satellite.setAttribute(QGeoSatelliteInfo::Azimuth, 200.0);
    satellite.setAttribute(QGeoSatelliteInfo::Elevation, 60.0);
    satellite.setSatelliteIdentifier(131);
    satellite.setSatelliteSystem(QGeoSatelliteInfo::GPS);
    satellite.setSignalStrength(30);
    satellites.append(satellite);

    satellite.setAttribute(QGeoSatelliteInfo::Azimuth, 80.0);
    satellite.setAttribute(QGeoSatelliteInfo::Elevation, 45.0);
    satellite.setSatelliteIdentifier(9);
    satellite.setSatelliteSystem(QGeoSatelliteInfo::GPS);
    satellite.setSignalStrength(22);
    satellites.append(satellite);

    satellite.setAttribute(QGeoSatelliteInfo::Azimuth, 120.0);
    satellite.setAttribute(QGeoSatelliteInfo::Elevation, 40.0);
    satellite.setSatelliteIdentifier(21);
    satellite.setSatelliteSystem(QGeoSatelliteInfo::GLONASS);
    satellite.setSignalStrength(16);
    satellites.append(satellite);
    satellitesInUse.append(satellite);

    satellite.setAttribute(QGeoSatelliteInfo::Azimuth, 250.0);
    satellite.setAttribute(QGeoSatelliteInfo::Elevation, 60.0);
    satellite.setSatelliteIdentifier(228);
    satellite.setSatelliteSystem(QGeoSatelliteInfo::GPS);
    satellite.setSignalStrength(3);
    satellites.append(satellite);
    satellitesInUse.append(satellite);

    satellite.setAttribute(QGeoSatelliteInfo::Azimuth, 280.0);
    satellite.setAttribute(QGeoSatelliteInfo::Elevation, 75.0);
    satellite.setSatelliteIdentifier(247);
    satellite.setSatelliteSystem(QGeoSatelliteInfo::GPS);
    satellite.setSignalStrength(0);
    satellites.append(satellite);

    satellitesInViewUpdated(satellites);
    satellitesInUseUpdated(satellitesInUse);

    QGeoPositionInfo position;
    position.setAttribute(QGeoPositionInfo::Direction, 24.0);
    positionUpdated(position);
}
