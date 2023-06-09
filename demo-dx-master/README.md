# Base Magnolia Java webapp

created using the following Maven command:

    mvn archetype:generate \
        -DarchetypeGroupId=info.magnolia.maven.archetypes \
        -DarchetypeArtifactId=magnolia-dx-core-custom-cloud-archetype \
        -DarchetypeVersion=1.3

using these values:

    groupId: info.magnolia.cloud
    artifactId: demo
    version: 1.0-SNAPSHOT
    package: info.magnolia.cloud
    magnolia-bundle-version: 6.2.18
    project-name: demo
    shortname: demo

And then:

    cd demo
    mvn archetype:generate \
    -DarchetypeGroupId=info.magnolia.maven.archetypes \
    -DarchetypeArtifactId=magnolia-module-archetype \
    -DarchetypeVersion=1.3

using these values:

    module-class-name: DemoModule
    magnolia-bundle-version: 6.2.18
    groupId: info.magnolia.cloud.demo
    artifactId: demo
    version: 1.0-SNAPSHOT
    package: info.magnolia.cloud.demo
    module-name: demo-module

    
Please refer to https://maven.apache.org/archetype/maven-archetype-plugin/archetype-repository.html for configuring the archetype resolution and add this repository to your active profile in your ~/.m2/settings.xml:

    <repository>
        <id>archetype</id><!-- id expected by maven-archetype-plugin to avoid fetching from everywhere -->
        <url>nexus.magnolia-cms.com/content/repositories/magnolia.public.releases</url>
        <releases>
            <enabled>true</enabled>
            <checksumPolicy>fail</checksumPolicy>
        </releases>
        <snapshots>
            <enabled>true</enabled>
            <checksumPolicy>warn</checksumPolicy>
        </snapshots>
    </repository>