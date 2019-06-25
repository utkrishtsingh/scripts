#!/usr/bin/env bash

app_name=$1
domain_name=$2
package_name=$3
src_code_path=""
#test_code_path=""
#resources_path=""

scaffold() {
	mkdir -p $app_name/{lib,src/{main/{java/$domain_name/{asp,controller},resources},test}}
	cp ~/Downloads/ojdbc7-12.1.0.1.jar $app_name/lib/
	cd $app_name
}

generate_projectfiles() {

cat > build.gradle << EOF
buildscript {

    repositories {
        mavenCentral()
    }
    dependencies {
        classpath("org.springframework.boot:spring-boot-gradle-plugin:\${springbootversion}")
    }

}

// Apply the java plugin to add support for Java
apply plugin: 'java'
apply plugin: 'org.springframework.boot'

//Jar Information 
jar {
    baseName = "$app_name"
    version = "0.0.1.SNAPSHOT"
}
// In this section you declare where to find the dependencies of your project
repositories {
    // Use 'jcenter' for resolving your dependencies.
    // You can declare any Maven/Ivy/file repository here.
    mavenCentral()
    jcenter()
}

// In this section you declare the dependencies for your production and test code
dependencies {
    // The production code uses the SLF4J logging API at compile time
    compile 'org.slf4j:slf4j-api:1.7.25'

    //Spring Dependencies
    compile ("org.springframework.boot:spring-boot-starter-web:\${springbootversion}")
    compile ("org.springframework.boot:spring-boot-starter-actuator")
    compile ("org.springframework.boot:spring-boot-starter-parent:\${springbootversion}")
    compile ("org.springframework.boot:spring-boot-starter-aop:\${springbootversion}")
    //compile ("org.springframework.boot:spring-boot-starter-data-jpa")
    //compile ("org.springframework.boot:spring-boot-devtools")

    //Jackson
    compile ("org.codehaus.jackson:jackson-mapper-asl:1.9.0")
    compile ("org.codehaus.jackson:jackson-core-asl:1.1.0")
    compile ("com.fasterxml.jackson.core:jackson-annotations:\${jacksonversion}")
    compile ("com.fasterxml.jackson.core:jackson-databind:\${jacksonversion}")
    compile ("com.fasterxml.jackson.dataformat:jackson-dataformat-yaml:\${jacksonversion}")

    //Swagger2 Dependencies
    compile ("io.springfox:springfox-swagger2:2.7.0")
    compile ("io.springfox:springfox-swagger-ui:2.7.0")

    //OJDBC
    //compile files ("../$app_name/lib/ojdbc7-12.1.0.1.jar")

    // Declare the dependency for your favourite test framework you want to use in your tests.
    // TestNG is also supported by the Gradle Test task. Just change the
    // testCompile dependency to testCompile 'org.testng:testng:6.8.1' and add
    // 'test.useTestNG()' to your build script.
    testCompile 'junit:junit:4.12'
}
EOF

cat > gradle.properties << EOF
springbootversion=1.5.7.RELEASE
jacksonversion=2.9.0
EOF

}

generate_dotfiles() {

cat > .gitignore << EOF
*#
*.iml
*.ipr
*.iws
*.sw?
*~
.#*
.*.md.html
.DS_Store
.classpath
.editorconfig
.factorypath
.gradle
.idea
.metadata
.project
.recommenders
.settings
.springBeans
.vscode
/build
/code
MANIFEST.MF
_site/
activemq-data
bin
build
build.log
dependency-reduced-pom.xml
dump.rdb
interpolated*.xml
manifest.yml
overridedb.*
settings.xml
target
transaction-logs
EOF

cat > .gitattributes << EOF
# Handle line endings automatically for files detected as text
# and leave all files detected as binary untouched.
* text=auto

#
# The above will handle all files NOT found below
#
# These files are text and should be normalized (Convert crlf => lf)
*.css           text
*.df            text
*.htm           text
*.html          text
*.java          text
*.js            text
*.json          text
*.jsp           text
*.jspf          text
*.jspx          text
*.properties    text
*.sh            text
*.tld           text
*.txt           text
*.tag           text
*.tagx          text
*.xml           text
*.yml           text

# These files are binary and should be left untouched
# (binary is a macro for -text -diff)
*.class         binary
*.bat           binary
*.dll           binary
*.ear           binary
*.gif           binary
*.ico           binary
*.jar           binary
*.jpg           binary
*.jpeg          binary
*.png           binary
*.so            binary
*.war           binary
EOF

cp .gitignore .dockerignore

cat >> .dockerignore << EOF
Dockerfile.*
docker-compose.*.yml
EOF

}

generate_boilerplate() {

cat > src/main/java/$domain_name/Application.java <<EOF
package $package_name;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.ComponentScan;

@SpringBootApplication
@ComponentScan
public class Application {

    public static void main(String[] args) {

        SpringApplication.run(Application.class, args);

    }

}
EOF

cat > src/main/java/$domain_name/controller/PingController.java << EOF
package $package_name.controller;

import java.time.Instant;

import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.http.ResponseEntity;
import org.springframework.http.HttpStatus;

@RestController
public class PingController {

	@RequestMapping(value = "/ping", method = RequestMethod.GET)
	public ResponseEntity<String> getPing() {
		return new ResponseEntity<String>("UTC Timestamp :\\t{" + Instant.now().toString() + "}\\nMessage :\\t{Pong}", HttpStatus.OK);
	}
}
EOF

cat > src/main/java/$domain_name/asp/LoggingAspect.java << EOF
package $package_name.asp;
import org.aspectj.lang.ProceedingJoinPoint;
import org.aspectj.lang.annotation.Around;
import org.aspectj.lang.annotation.Aspect;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.util.StopWatch;

@Component
@Aspect
public class LoggingAspect {


    private static final Logger logger = LoggerFactory.getLogger(LoggingAspect.class);

    @Around("execution(* $package_name.controller.*.*(..))")
    public Object logTime(ProceedingJoinPoint joinPoint) throws Throwable {

        StopWatch stopWatch;
        stopWatch = new StopWatch();

        stopWatch.start(joinPoint.getTarget().getClass().toString());
        Object returnValue = joinPoint.proceed();
        stopWatch.stop();
        
        logger.info("$app_name :: " + joinPoint.getTarget().getClass().getName() + " :: " + joinPoint.getSignature().getName() + "() Invoked");
        logger.info("Time Elapsed (Stopwatch) : " + stopWatch.getTotalTimeMillis() + "ms");
        return returnValue;

    }

}
EOF

cat > src/main/resources/application.yml <<EOF
---
server:
  port: 3000
EOF

}
bootstrap() {
	scaffold
	generate_dotfiles
	generate_projectfiles
	generate_boilerplate

}

bootstrap
