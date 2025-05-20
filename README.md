# Proyecto Operati Test

Este proyecto consiste en una aplicación que descarga archivos Excel de páginas web utilizando Selenium, los procesa y almacena la información en una base de datos para su posterior consulta.

## Estructura del Proyecto

```
proyecto/
├── backend/    # Spring Boot API
└── frontend/   # Flutter Application
```

## Tecnologías Utilizadas

- **Backend**: Spring Boot 3.4.5 con Java 17
- **Frontend**: Flutter 3.6.0
- **Base de Datos**: MySQL 8.0.41
- **Web Scraping**: Selenium WebDriver

## Requisitos Previos

- Java 17+
- Flutter SDK 3.6.0+
- MySQL 8.0.41
- Maven 3.6+

## Configuración de la Base de Datos

1. Instalar MySQL 8.0.41
2. Crear la base de datos:
```sql
CREATE DATABASE operati_test;
```
3. Configurar usuario:
   - Usuario: `root`
   - Contraseña: `root`

## Instalación y Ejecución

Modificar el application.properties a las variables del sistema en el que se va a ejecutar

### Backend (Spring Boot)

1. Navegar al directorio del backend:
```bash
cd backend
```

2. Instalar dependencias:
```bash
mvn clean install
```

3. Ejecutar la aplicación:
```bash
mvn spring-boot:run
```

**Archivo principal**: `TestOperatiApplication.java`

**Puerto**: `8080`

**Perfil**: `dev`

### Frontend (Flutter)

1. Navegar al directorio del frontend:
```bash
cd frontend
```

2. Instalar dependencias:
```bash
flutter pub get
```

3. Ejecutar la aplicación:
```bash
flutter run --dart-define=API_URL=http://theApiip:port
```

## Endpoints Principales

Los endpoints principales se encuentran en el `CapacidadDemandaController`:

- `GET /api/capacidad-demanda/downloadFile` - Descarga archivo Excel y guarda datos en BD
- `GET /api/capacidad-demanda/getPaginated/{page}/{size}/{sortBy}/{direction}/{filter}` - Consulta paginada de datos

## Funcionalidades

1. **Descarga de Excel**: Utiliza Selenium para descargar archivos Excel desde páginas web
2. **Procesamiento**: Lee y procesa los datos del archivo Excel
3. **Almacenamiento**: Guarda la información en la base de datos MySQL
4. **Consulta**: Permite consultar los datos almacenados con paginación y filtros

## Documentación API

Una vez ejecutado el backend, la documentación Swagger estará disponible en:
```
http://localhost:8080/swagger-ui/index.html
```

## Estructura del Código

### Backend
- **Controllers**: Controladores REST API
- **Services**: Lógica de negocio
- **Models**: Entidades de base de datos
- **Utils**: Utilidades y respuestas personalizadas

### Frontend
- **Models**: Modelos de datos
- **Services**: Servicios para comunicación con API
- **Screens**: Pantallas de la aplicación

## Notas

- No se requiere Docker para la ejecución
- La aplicación no incluye scripts de inicialización de base de datos
- Asegúrese de que MySQL esté ejecutándose antes de iniciar el backend
