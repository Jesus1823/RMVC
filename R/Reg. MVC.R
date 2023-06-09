#' Regresión Multiple Con Variables Categóricas.
#'
#' Realiza predicciones con multiples variables categóricas.
#'
#' @param datos_entrenamiento (string) datos para ajustar el modelo con la
#' variable respuesta observada.
#' @param datos_prediccion (string) datos para realizar predicciones sin la
#' variable respuesta.
#' @param variable_dummy (string) datos cualitativos independientes.
#' @param var_resp (string) variable respuesta.
#' @return Devuelve una lista con los cálculos correspondientes para los valores ajustados con nuestro modelo, predicciones, errores en las predicciones.
#' @export
#'
#' @examples
#' \dontrun{
#' # Cargando la libreria de la función "RMVC"
#' library(RMVC)
#'
#' # Cargamos libreria necesaria para manejar NA.
#' library(dplyr)
#'
#' #____________________________________________________________________________
#' # Ejemplo 1:
#' # Cargamos datos de entrenamiendo
#' archivo <- "C:/Users/Jesus Alfredo/OneDrive/Documentos/RLVC conjunto de datos R/Datos_entrenamiento.csv"
#' datos_entrenamiento <- read.csv(archivo)
#'
#' # Cargamos datos de predicción
#' archivo_prediccion <- "C:/Users/Jesus Alfredo/OneDrive/Documentos/RLVC conjunto de datos R/Ddatos_predic.csv"
#' datos_prediccion <- read.csv(archivo_prediccion)
#'
#' # Llamamos la función "modelo_Regresion" para realizar predicciones de la variable y, en este caso del peso.
#' modelo_Regresion(datos_entrenamiento, datos_prediccion,
#'                 variable_dummy = c("Raza" + "Alimentacion" + "Edad" + "Clima"),
#'                 y)
#' #____________________________________________________________________________
#' # Ejemplo 2:
#' # Cargamos en un dataframe los datos de entranamiento.
#' datos_entrenamiento <- data.frame(y = c(585, 632, 674, 663, 567, 599, 638, 586),
#'                                   Raza = c("Angus", "Herenford", "Charolais", "Simmental", "Angus", "Herenford", "Charolais", "Simmental"),
#'                                   Alimentacion = c("Ensilado", "Ensilado", "Ensilado", "Ensilado", "Pastoreo", "Pastoreo", "Pastoreo", "Pastoreo"))
#'
#' # Cargamos en un dataframe los datos para predecir.
#' datos_prediccion <- data.frame(Raza = c("Charolais", "Angus", "Herenford", "Simmental", "Angus", "Herenford", "Simmental", "Charolais"),
#'                                Alimentacion = c("Pastoreo", "Pastoreo", "Pastoreo", "Pastoreo", "Ensilado", "Ensilado", "Ensilado", "Ensilado"))
#'
#'# Llamamos la función "modelo_Regresion" para realizar predicciones de la variable y, en este caso del peso.
#' modelo_Regresion(datos_entrenamiento,
#'                 datos_prediccion,
#'                 variable_dummy = c("Raza" + "Alimentacion"),
#'                 y)
#' }
# Función para realizar predicciones de regresión lineal con variables dummy
predic_RMVC <- function(trainning, testing, regresoras, y) {

  # convertir los archivos en data.frame
  de <- data.frame(trainning)
  dp <- data.frame(testing)

  # Agregar la columna 'Y' con valores NA y reordenar las columnas
  dp_NA <- dp %>%
    mutate(y = NA) %>%
    select(y, everything())

  # Ajustar los nombres de las columnas en dp_NA para que coincidan con los de de
  colnames(dp_NA) <- colnames(de)

  # Combinar los data.frames en uno solo
  df_NA <- rbind(dp_NA, de)

  # Convertimos a variables dummy
  f <- as.formula(paste0("~", paste0(colnames(df_NA[,-1]), collapse="+")))
  X = model.matrix(f, df_NA)

  ## definimos "y" y las "x" sin valores faltantes
  colnames(df_NA)[1] <- "y"
  idNA <- is.na(df_NA$y)
  y <- df_NA$y[!idNA]
  X_entrenamiento <- X[!idNA, ]
  X_prediccion <- X[idNA, ]
  n <- length(y)
  p <- ncol(X)

  # Calculamos los coeficientes utilizando la ecuación normal
  beta <- solve(t(X_entrenamiento) %*% X_entrenamiento) %*% t(X_entrenamiento) %*% y

  # Calculamos los valores de y ajustados y realizamos las predicciones
  Ajustado <- X_entrenamiento %*% beta
  Predicciones <- X_prediccion %*% beta

  # Calculo de ECM
  ecm = sum((y - Ajustado)^2)/(n-p)
  # Resultados en forma de lista
  resultados <- list(Ajustado <- data.frame(Ajustado),
                     Predicciones <- data.frame(cbind(Predicciones, dp)),
                     ECM <- data.frame(ecm))

  return(resultados)
}
