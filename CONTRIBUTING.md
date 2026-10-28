<p align="center">
  <h1 align="center">Guía de Contribución</h1>
  <p align="center"><strong>Directrices y flujos de trabajo para colaborar en Nexora Suite</strong></p>
</p>

---

## Tabla de Contenidos

- [Bienvenida](#bienvenida)
- [Antes de empezar](#antes-de-empezar)
- [Flujo de trabajo](#flujo-de-trabajo)
- [Entorno de desarrollo](#entorno-de-desarrollo)
- [Estándares de código](#estándares-de-código)
- [Checklist del Pull Request](#checklist-del-pull-request)
- [Proceso de revisión](#proceso-de-revisión)
- [Acuerdo de contribución (CLA)](#acuerdo-de-contribución-cla)
- [Código de conducta](#código-de-conducta)
- [Licencia](#licencia)

---

## Bienvenida

Agradecemos tu interés en colaborar con Nexora Suite. Este proyecto es el centro de control y gestor de aplicaciones del ecosistema Nexora para Windows y Linux. Las contribuciones orientadas a mejorar la calidad, estructura o rendimiento del software son bienvenidas.

## Antes de empezar

Para evitar esfuerzos duplicados o cambios que no se alineen con la visión del proyecto, te solicitamos seguir estas pautas iniciales:

- **Cambios menores (corrección de erratas, bugfixes simples):** Puedes abrir directamente un Pull Request.
- **Cambios mayores o nuevas características:** Abre primero un **Issue** para discutir la propuesta con el equipo mantenedor antes de comenzar a escribir código.

## Flujo de trabajo

Sigue estos pasos para realizar contribuciones al repositorio:

1. Realiza un **Fork** de este repositorio en tu cuenta personal de GitHub.
2. Crea una rama descriptiva siguiendo las convenciones de nomenclatura:
   - `feat/nombre-funcionalidad` para nuevas características.
   - `fix/descripcion-error` para correcciones de errores.
   - `docs/nombre-documento` para mejoras en la documentación.
   - `refactor/zona-afectada` para reestructuración de código sin cambio de comportamiento.
3. Realiza tus cambios utilizando **Conventional Commits** (ejemplo: `feat(core): agregar soporte para variables de entorno`).
4. Sube la rama a tu fork y abre un **Pull Request** hacia la rama principal del proyecto original.

## Entorno de desarrollo

Para configurar el entorno de trabajo localmente, ejecuta los siguientes comandos:

```bash
# Instalar dependencias de Flutter
flutter pub get

# Ejecutar en Linux
flutter run -d linux

# Ejecutar en Windows
flutter run -d windows

# Analizar el código
flutter analyze

# Compilar el núcleo Rust (opcional)
cd rust/nexora_core
cargo build --release
cd ../..
```

## Estándares de código

- **Dart/Flutter:** Sigue las reglas definidas en `analysis_options.yaml` y ejecuta `flutter analyze` antes de enviar un PR.
- **Estilo:** Mantén la estética monocromática (negro `#090C02`, blanco `#EBF5EE`, grises neutros) y el acento `#A50021`.
- **Rust:** Formatea con `cargo fmt` y valida con `cargo clippy` cuando modifiques `rust/nexora_core`.
- **Commits:** Usa Conventional Commits para mantener un historial claro.

## Checklist del Pull Request

Antes de enviar tu PR, verifica lo siguiente:

- [ ] El código compila sin errores (`flutter build linux` o `flutter build windows`).
- [ ] `flutter analyze` no reporta errores.
- [ ] La interfaz mantiene la estética monocromática de Nexora.
- [ ] Se actualizaron las pruebas o documentación afectadas.
- [ ] El PR describe claramente el cambio y su motivación.

## Proceso de revisión

Los mantenedores revisarán tu PR y podrán solicitar cambios. Una vez aprobado, se integrará a la rama principal.

## Acuerdo de contribución (CLA)

Al contribuir, aceptas que tus aportes se licencien bajo los términos de la licencia del proyecto (PolyForm Noncommercial 1.0.0).

## Código de conducta

Trata a todos los colaboradores con respeto. No se tolerará el acoso ni la discriminación.

## Licencia

Este proyecto se distribuye bajo los términos de la licencia **PolyForm Noncommercial 1.0.0**. Consulta [LICENSE](LICENSE) para más detalles.
