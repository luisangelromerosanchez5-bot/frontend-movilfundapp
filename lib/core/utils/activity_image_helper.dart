/// Helper para mapear y resolver de forma inteligente las ilustraciones oficiales
/// de cada actividad, garantizando que tanto desde el backend remoto (Render)
/// como desde el almacenamiento local se visualicen las fichas ilustradas oficiales.
class ActivityImageHelper {
  ActivityImageHelper._();

  static const Map<String, String> _keywordToAsset = {
    'ingles': 'assets/images/act_clases_ingles.png',
    'english': 'assets/images/act_clases_ingles.png',
    'digital': 'assets/images/act_alfabetizacion_digital.png',
    'alfabetizacion': 'assets/images/act_alfabetizacion_digital.png',
    'computador': 'assets/images/act_alfabetizacion_digital.png',
    'pintura': 'assets/images/act_taller_pintura.png',
    'oleo': 'assets/images/act_taller_pintura.png',
    'arte': 'assets/images/act_taller_pintura.png',
    'matematic': 'assets/images/act_refuerzo_matematico.png',
    'calculo': 'assets/images/act_refuerzo_matematico.png',
    'vocacional': 'assets/images/act_orientacion_vocacional.png',
    'orientacion': 'assets/images/act_orientacion_vocacional.png',
    'comedor': 'assets/images/act_comedor_comunitario.png',
    'entredor': 'assets/images/act_entredor_comunitario.png',
    'mercado': 'assets/images/act_entrega_mercados.png',
    'viveres': 'assets/images/act_entrega_mercados.png',
    'hambre': 'assets/images/act_campana_hambre.png',
    'cocina': 'assets/images/act_cocina_saludable.png',
    'desayuno': 'assets/images/act_desayuno_solidario.png',
    'banco de alimentos': 'assets/images/act_banco_alimentos.png',
    'oral infantil': 'assets/images/act_salud_oral_2.png',
    'salud oral': 'assets/images/act_salud_oral_1.png',
    'dientes': 'assets/images/act_salud_oral_1.png',
    'odontol': 'assets/images/act_salud_oral_1.png',
    'estres': 'assets/images/act_manejo_estres.png',
    'mindfulness': 'assets/images/act_manejo_estres.png',
    'relajacion': 'assets/images/act_manejo_estres.png',
    'sangre': 'assets/images/act_donacion_sangre.png',
    'diabetes': 'assets/images/act_prevencion_diabetes.png',
    'parque': 'assets/images/act_limpieza_parques.png',
    'limpieza parques': 'assets/images/act_limpieza_parques.png',
    'feria': 'assets/images/act_feria_vida_saludable.png',
    'vida saludable': 'assets/images/act_feria_vida_saludable.png',
    'zumba': 'assets/images/act_feria_vida_saludable.png',
    'materna': 'assets/images/act_nutricion_materna.png',
    'lactancia': 'assets/images/act_nutricion_materna.png',
    'cena benefica': 'assets/images/act_nutricion_materna.png',
    'cena': 'assets/images/act_nutricion_materna.png',
    'escritura': 'assets/images/act_escritura_creativa.png',
    'salud mental': 'assets/images/act_salud_mental.png',
    'cerebro': 'assets/images/act_salud_mental.png',
    'ajedrez': 'assets/images/act_club_ajedrez.png',
    'primeros auxilios': 'assets/images/act_primeros_auxilios.png',
    'auxilio': 'assets/images/act_primeros_auxilios.png',
    'rcp': 'assets/images/act_primeros_auxilios.png',
    'zonas verdes': 'assets/images/act_limpiar_zonas_verdes.png',
    'limpiar zonas': 'assets/images/act_limpiar_zonas_verdes.png',
    'padres': 'assets/images/act_escuela_padres.png',
    'familia': 'assets/images/act_escuela_padres.png',
    'optometrica': 'assets/images/act_brigada_optometrica.png',
    'ojos': 'assets/images/act_brigada_optometrica.png',
    'vision': 'assets/images/act_brigada_optometrica.png',
    'visual': 'assets/images/act_brigada_optometrica.png',
    'panaderia': 'assets/images/act_jornada_panaderia.png',
    'pan': 'assets/images/act_jornada_panaderia.png',
    'huerta': 'assets/images/act_huerta_urbana.png',
    'compostaje': 'assets/images/act_huerta_urbana.png',
    'robotica': 'assets/images/act_robotica_junior.png',
    'lectura': 'assets/images/act_lectura_infantil.png',
    'cuento': 'assets/images/act_lectura_infantil.png',
    'libro': 'assets/images/act_lectura_infantil.png',
    'reforestacion': 'assets/images/act_reforestacion_rio.jpg',
    'rio bosque': 'assets/images/act_reforestacion_rio.jpg',
    'siembra': 'assets/images/act_reforestacion_rio.jpg',
    'reciclaje': 'assets/images/act_reciclaje_urbano.jpg',
    'humedal': 'assets/images/act_humedal_cordoba.jpg',
    'aves': 'assets/images/act_aves_silvestres.jpg',
    'frailejon': 'assets/images/act_paramo_frailejones.jpg',
    'paramo': 'assets/images/act_paramo_frailejones.jpg',
    'escolar': 'assets/images/act_educacion_ambiental.jpg',
    'colegio': 'assets/images/act_educacion_ambiental.jpg',
  };

  static String _normalize(String input) {
    var s = input.toLowerCase();
    s = s.replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u');
    s = s.replaceAll('ñ', 'n');
    return s;
  }

  static String resolveImage(String title, [String? currentImageUrl]) {
    if (currentImageUrl != null &&
        currentImageUrl.startsWith('assets/images/act_') &&
        !currentImageUrl.contains('unsplash')) {
      return currentImageUrl;
    }

    final normalizedTitle = _normalize(title);

    for (final entry in _keywordToAsset.entries) {
      if (normalizedTitle.contains(entry.key)) {
        return entry.value;
      }
    }

    if (currentImageUrl != null && currentImageUrl.isNotEmpty && !currentImageUrl.contains('unsplash')) {
      return currentImageUrl;
    }

    return 'assets/images/act_reforestacion_rio.jpg';
  }
}
