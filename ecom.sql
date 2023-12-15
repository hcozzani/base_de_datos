-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Servidor: 127.0.0.1
-- Tiempo de generación: 25-11-2023 a las 00:25:17
-- Versión del servidor: 10.4.28-MariaDB
-- Versión de PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `ecom`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `agregarCantidadStock` (IN `p_idProducto` INT, IN `p_talleTexto` VARCHAR(255), IN `p_cantidad` INT)   BEGIN
    DECLARE v_idTalle INT;
    DECLARE v_count INT;

    -- Buscar el ID del talle correspondiente al texto proporcionado
    SELECT id INTO v_idTalle FROM talle WHERE talleCodigo = p_talleTexto;

    -- Verificar si se encontró un ID de talle válido
    IF v_idTalle IS NOT NULL THEN
        -- Verificar si ya existe una entrada para el producto y talle
        SELECT COUNT(*) INTO v_count FROM producto_talle WHERE idProducto = p_idProducto AND idTalle = v_idTalle;

        -- Si ya existe, actualizar la cantidad; de lo contrario, realizar la inserción
        IF v_count > 0 THEN
            UPDATE producto_talle
            SET cantidad = cantidad + p_cantidad
            WHERE idProducto = p_idProducto AND idTalle = v_idTalle;
        ELSE
            INSERT INTO producto_talle (idProducto, idTalle, cantidad)
            VALUES (p_idProducto, v_idTalle, p_cantidad);
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `agregarStock` (IN `p_idProducto` INT, IN `p_talleTexto` VARCHAR(255), IN `p_cantidad` INT)   BEGIN
    DECLARE v_idTalle INT;
    DECLARE v_count INT;

    -- Buscar el ID del talle correspondiente al texto proporcionado
    SELECT id INTO v_idTalle FROM talle WHERE talleCodigo = p_talleTexto;

    -- Verificar si se encontró un ID de talle válido
    IF v_idTalle IS NOT NULL THEN
        -- Verificar si ya existe una entrada para el producto y talle
        SELECT COUNT(*) INTO v_count FROM producto_talle WHERE idProducto = p_idProducto AND idTalle = v_idTalle;

        -- Si ya existe, actualizar la cantidad; de lo contrario, realizar la inserción
        IF v_count > 0 THEN
            UPDATE producto_talle
            SET cantidad = cantidad + p_cantidad
            WHERE idProducto = p_idProducto AND idTalle = v_idTalle;
        ELSE
            INSERT INTO producto_talle (idProducto, idTalle, cantidad)
            VALUES (p_idProducto, v_idTalle, p_cantidad);
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `altaProducto` (IN `p_nombre` VARCHAR(255), IN `p_precio` DECIMAL(10,2), IN `p_porcentajeGanancia` DECIMAL(10,2), IN `p_categoriaNombre` VARCHAR(255), IN `p_talleCodigo` VARCHAR(255), IN `p_cantidad` INT, IN `p_img` VARCHAR(255))   BEGIN
    DECLARE v_idProducto INT;
    DECLARE v_idCategoria INT;
    DECLARE v_idTalle INT;

    -- Obtener el ID de la categoría a partir del nombre
    SELECT id INTO v_idCategoria FROM categorias WHERE categoriaNombre = p_categoriaNombre;

    -- Obtener el ID del talle a partir del código
    SELECT id INTO v_idTalle FROM talle WHERE talleCodigo = p_talleCodigo;

    -- Insertar el producto en la tabla productos
    INSERT INTO productos (nombre, categoriaId, img) VALUES (p_nombre, v_idCategoria, p_img);

    -- Obtener el ID del producto recién insertado
    SET v_idProducto = LAST_INSERT_ID();

    -- Insertar el precio en la tabla precios
    INSERT INTO precio (idProducto, precioCosto, porcentajeGanancia)
    VALUES (v_idProducto, p_precio, p_porcentajeGanancia);

    -- Insertar el producto y el talle en la tabla producto_talle
    INSERT INTO producto_talle (idProducto, idTalle, cantidad)
    VALUES (v_idProducto, v_idTalle, p_cantidad);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `compraProducto` (IN `p_ProductoTalleId` INT, IN `p_cantidadVender` INT)   BEGIN
    DECLARE v_ProductoTalleId INT;
    DECLARE v_cantidadProductoTalle INT;
	DECLARE v_cantidadActual INT;
    

    -- Obtener el ID en producto talle
    SELECT id INTO v_ProductoTalleId
    FROM producto_talle
    WHERE id = p_ProductoTalleId;
    
    -- Obtener cantidad en la tabla producto talle
    SELECT cantidad INTO v_cantidadProductoTalle
    FROM producto_talle
    WHERE id = p_ProductoTalleId;
    
    SET v_cantidadActual = v_cantidadProductoTalle - p_cantidadVender;

    -- Actualizar la cantidad en alumno materia
    UPDATE producto_talle
    SET cantidad = v_cantidadActual
    WHERE id = p_ProductoTalleId;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `modificarProducto` (IN `p_idProducto` INT, IN `p_nombre` VARCHAR(255), IN `p_precio` DECIMAL(10,2), IN `p_porcentajeGanancia` DECIMAL(10,2), IN `p_categoriaNombre` VARCHAR(255), IN `p_talleCodigo` VARCHAR(255), IN `p_cantidad` INT, IN `p_img` VARCHAR(255))   BEGIN
    DECLARE v_idCategoria INT;
    DECLARE v_idTalle INT;

    -- Obtener el ID de la categoría a partir del nombre
    SELECT id INTO v_idCategoria FROM categorias WHERE categoriaNombre = p_categoriaNombre;

    -- Obtener el ID del talle a partir del código
    SELECT id INTO v_idTalle FROM talle WHERE talleCodigo = p_talleCodigo;

    -- Actualizar la información del producto en la tabla productos
    UPDATE productos
    SET nombre = p_nombre, categoriaId = v_idCategoria
    WHERE id = p_idProducto;


    -- Actualizar el precio en la tabla precios
    UPDATE precio
    SET precioCosto = p_precio, porcentajeGanancia = p_porcentajeGanancia
    WHERE idProducto = p_idProducto;

    -- Actualizar la información del producto y el talle en la tabla producto_talle
UPDATE productos 
    SET nombre = p_nombre, 
        precio = p_precio, 
        categoriaId = v_idCategoria, 
        img = p_img
    WHERE id = p_idProducto;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `modProducto` (IN `p_id` INT, IN `p_nombre` VARCHAR(20), IN `p_precio` INT, IN `p_categoria` VARCHAR(20))   BEGIN
    DECLARE v_categoriaId INT;
    
    -- Obtener el ID en categoria mediante parametro
    SELECT id INTO v_categoriaId
    FROM categorias
    WHERE  categoriaNombre = p_categoria;
	UPDATE productos set nombre = p_nombre, precio = p_precio, categoriaId = v_categoriaId where id = p_id;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `categorias`
--

CREATE TABLE `categorias` (
  `id` int(11) NOT NULL,
  `categoriaNombre` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `categorias`
--

INSERT INTO `categorias` (`id`, `categoriaNombre`) VALUES
(1, 'remera'),
(2, 'buzo'),
(3, 'camisa'),
(4, 'pantalon'),
(5, 'vestido');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `precio`
--

CREATE TABLE `precio` (
  `id` int(11) NOT NULL,
  `idProducto` int(11) DEFAULT NULL,
  `precioCosto` int(11) DEFAULT NULL,
  `porcentajeGanancia` int(11) DEFAULT NULL,
  `precioVenta` int(11) GENERATED ALWAYS AS (`precioCosto` * (1 + `porcentajeGanancia` / 100)) VIRTUAL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `precio`
--

INSERT INTO `precio` (`id`, `idProducto`, `precioCosto`, `porcentajeGanancia`) VALUES
(32, 1, 9200, 10),
(33, 2, 8400, 10),
(34, 3, 7800, 10),
(35, 4, 6300, 10),
(36, 5, 5300, 10),
(37, 6, 5600, 10),
(38, 7, 6500, 10),
(39, 8, 12000, 10),
(40, 9, 5600, 10),
(41, 10, 8900, 10),
(42, 11, 8600, 10),
(43, 12, 14900, 10),
(44, 13, 14900, 10),
(45, 14, 8800, 10),
(46, 15, 24800, 10),
(47, 16, 15600, 10),
(48, 17, 10400, 10),
(49, 18, 13900, 10),
(50, 19, 22400, 10),
(51, 20, 14600, 10),
(126, 34, 7000, 22),
(127, 35, 3000, 10),
(128, 36, 7000, 15),
(129, 37, 9700, 12),
(130, 38, 4500, 12),
(131, 39, 9700, 12),
(132, 40, 5000, 10),
(133, 41, 4000, 15);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `productos`
--

CREATE TABLE `productos` (
  `id` int(11) NOT NULL,
  `nombre` varchar(20) DEFAULT NULL,
  `precio` int(11) DEFAULT NULL,
  `categoriaId` int(11) DEFAULT NULL,
  `img` varchar(50) DEFAULT NULL,
  `fechaAlta` datetime DEFAULT NULL,
  `usuarioAlta` varchar(255) DEFAULT NULL,
  `fechaMod` datetime DEFAULT NULL,
  `usuarioMod` varchar(255) DEFAULT NULL,
  `fechaBaja` datetime DEFAULT NULL,
  `usuarioBaja` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `productos`
--

INSERT INTO `productos` (`id`, `nombre`, `precio`, `categoriaId`, `img`, `fechaAlta`, `usuarioAlta`, `fechaMod`, `usuarioMod`, `fechaBaja`, `usuarioBaja`) VALUES
(1, 'euphoria', 9200, 1, 'img/euphoria.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(2, 'farah', 8400, 1, 'img/farah.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(3, 'helen', 7800, 1, 'img/helen.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(4, 'nerea', 6300, 1, 'img/nerea.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(5, 'nature', 5300, 1, 'img/nature.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(6, 'selena', 5600, 2, 'img/selena.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(7, 'constance', 6500, 2, 'img/constance.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(8, 'dream', 12000, 2, 'img/dream.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(9, 'lucky', 5600, 2, 'img/lucky.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(10, 'happy', 8900, 3, 'img/happy.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(11, 'margie', 8600, 3, 'img/margie.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(12, 'jackie', 14900, 3, 'img/jackie.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(13, 'ornella', 14900, 3, 'img/ornella.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(14, 'alegra', 8800, 3, 'img/allegra.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(15, 'nikki', 24800, 3, 'img/nikki.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(16, 'lukka', 15600, 4, 'img/lukka.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(17, 'dylan', 10400, 4, 'img/dylan.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(18, 'mikkel', 13900, 4, 'img/mikkel.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(19, 'selva', 22400, 5, 'img/selva.webp', NULL, NULL, '2023-10-29 07:26:47', 'root@localhost', '0000-00-00 00:00:00', NULL),
(20, 'parker', 14600, 4, 'img/parker.webp', NULL, NULL, NULL, NULL, NULL, NULL),
(32, 'prueba', 234, 1, NULL, '2023-10-29 07:34:04', 'root@localhost', '2023-10-29 07:40:26', 'root@localhost', NULL, NULL),
(33, 'prueba2', NULL, 1, NULL, '2023-10-29 08:41:54', 'root@localhost', NULL, NULL, NULL, NULL),
(34, 'editadoPrueba', NULL, 1, NULL, '2023-10-29 08:43:55', 'root@localhost', '2023-11-03 19:00:52', 'root@localhost', '2023-10-29 15:31:24', 'root@localhost'),
(35, 'pruebaEdit', NULL, 3, NULL, '2023-10-29 08:51:53', 'root@localhost', '2023-10-29 10:18:33', 'root@localhost', '2023-10-29 14:18:33', 'root@localhost'),
(36, 'pruebaClase', NULL, 3, NULL, '2023-11-03 18:40:31', 'root@localhost', '2023-11-23 20:40:24', 'root@localhost', '2023-11-24 00:40:24', 'root@localhost'),
(37, 'PruebaViernesCambioS', NULL, 3, NULL, '2023-11-10 16:36:23', 'root@localhost', '2023-11-23 20:40:40', 'root@localhost', '2023-11-24 00:40:40', 'root@localhost'),
(38, 'image', 4500, 3, 'img/margie.webp', '2023-11-23 20:35:36', 'root@localhost', '2023-11-24 16:23:06', 'root@localhost', '2023-11-24 20:23:06', 'root@localhost'),
(39, 'pruebaProc', NULL, 3, 'img/logo.png', '2023-11-23 20:53:31', 'root@localhost', '2023-11-24 16:22:51', 'root@localhost', '2023-11-24 20:22:51', 'root@localhost'),
(40, 'pruebaFinal', NULL, NULL, 'img/helen.webp', '2023-11-24 11:56:39', 'root@localhost', '2023-11-24 16:35:47', 'root@localhost', NULL, 'algo'),
(41, 'pruebaModificacion', 4000, 2, 'img/allegra.webp', '2023-11-24 12:17:27', 'root@localhost', '2023-11-24 16:39:03', 'root@localhost', NULL, NULL);

--
-- Disparadores `productos`
--
DELIMITER $$
CREATE TRIGGER `insertProducto` BEFORE INSERT ON `productos` FOR EACH ROW BEGIN
    SET NEW.usuarioAlta = USER();
    SET NEW.fechaAlta = NOW();
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `updateProductos` BEFORE UPDATE ON `productos` FOR EACH ROW BEGIN
    SET NEW.usuarioMod = USER();
    SET NEW.fechaMod = NOW();
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `producto_talle`
--

CREATE TABLE `producto_talle` (
  `id` int(11) NOT NULL,
  `idProducto` int(11) DEFAULT NULL,
  `idTalle` int(11) DEFAULT NULL,
  `cantidad` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `producto_talle`
--

INSERT INTO `producto_talle` (`id`, `idProducto`, `idTalle`, `cantidad`) VALUES
(42, 1, 4, 98),
(43, 2, 4, 94),
(44, 3, 4, 98),
(45, 4, 4, 100),
(46, 5, 4, 100),
(47, 6, 4, 100),
(48, 7, 4, 99),
(49, 8, 4, 100),
(50, 9, 4, 100),
(51, 10, 4, 100),
(52, 11, 4, 100),
(53, 12, 4, 100),
(54, 13, 4, 100),
(55, 14, 4, 100),
(56, 15, 4, 100),
(57, 16, 4, 100),
(58, 17, 4, 100),
(59, 18, 4, 100),
(60, 19, 4, 100),
(61, 20, 4, 100),
(93, 1, 3, 98),
(94, 2, 3, 99),
(95, 3, 3, 99),
(96, 4, 3, 100),
(97, 5, 3, 100),
(98, 6, 3, 100),
(99, 7, 3, 100),
(100, 8, 3, 100),
(101, 9, 3, 100),
(102, 10, 3, 100),
(103, 11, 3, 100),
(104, 12, 3, 100),
(105, 13, 3, 100),
(106, 14, 3, 100),
(107, 15, 3, 100),
(108, 16, 3, 100),
(109, 17, 3, 100),
(110, 18, 3, 100),
(111, 19, 3, 100),
(112, 20, 3, 100),
(124, 32, 3, 150),
(125, 33, 4, 150),
(126, 34, 1, 44),
(127, 35, 5, 500),
(136, NULL, 5, 355),
(137, NULL, 1, 44),
(138, NULL, 4, 11),
(139, NULL, 5, 15),
(141, NULL, 5, 134),
(142, NULL, 1, 1000),
(143, 36, 3, 10),
(148, 34, 1, 65),
(149, 37, 3, 50),
(151, 37, 6, 160),
(152, 38, 5, 150),
(153, 38, 5, 150),
(154, 39, 5, 150),
(159, 3, 2, 11),
(160, 40, 4, 150),
(161, 41, 5, 150);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `talle`
--

CREATE TABLE `talle` (
  `id` int(11) NOT NULL,
  `talleCodigo` varchar(4) DEFAULT NULL,
  `talleNombre` varchar(20) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `talle`
--

INSERT INTO `talle` (`id`, `talleCodigo`, `talleNombre`) VALUES
(1, 'XS', 'extra pequeño'),
(2, 'S', 'pequeño'),
(3, 'M', 'medio'),
(4, 'L', 'Grande'),
(5, 'XL', 'extra grande'),
(6, 'XXL', 'doble extra grande');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `apellido` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `telefono` varchar(50) DEFAULT NULL,
  `valorSalt` varchar(50) DEFAULT NULL,
  `hashContrasena` varchar(100) NOT NULL,
  `rol` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `nombre`, `apellido`, `email`, `telefono`, `valorSalt`, `hashContrasena`, `rol`) VALUES
(15, 'Elias', 'Alegre', 'eliasalegre96@gmail.com', '01130615889', '98cb78afacc3d72e69f6bdc1fee476c2', '$2y$10$aZ6Ou96BG9J4wzRAn4HVQuU1bjyIx8ijacLCTc8pl81YGe8CvltiC', 'administrador'),
(17, 'Elias', 'Alegre', 'eliasUsuarioComun@gmail.com', '01130615889', '1731a9bf2700e8fcbaa9a3f6ee8df2b0', '$2y$10$4RoB8ZRv/yTM3hpbtp7wVeQDit8pf16MT7swhGSNS2rIp63U2V4vC', 'usuario'),
(18, 'Pedro', 'Bondonno', 'abcde@gmail.com', '01127535916', 'c0f5bf17eb7e13c342285cc63bb50f01', '$2y$10$v.OIRRWJVqZHrhsuDZ72g.bpqmlwSfF6Db7LnhDS8K9LFlLtmOQHC', 'administrador');

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `categorias`
--
ALTER TABLE `categorias`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `precio`
--
ALTER TABLE `precio`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idProducto` (`idProducto`);

--
-- Indices de la tabla `productos`
--
ALTER TABLE `productos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `categoriaId` (`categoriaId`);

--
-- Indices de la tabla `producto_talle`
--
ALTER TABLE `producto_talle`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idProducto` (`idProducto`),
  ADD KEY `idTalle` (`idTalle`);

--
-- Indices de la tabla `talle`
--
ALTER TABLE `talle`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `categorias`
--
ALTER TABLE `categorias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT de la tabla `precio`
--
ALTER TABLE `precio`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=134;

--
-- AUTO_INCREMENT de la tabla `productos`
--
ALTER TABLE `productos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=42;

--
-- AUTO_INCREMENT de la tabla `producto_talle`
--
ALTER TABLE `producto_talle`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=162;

--
-- AUTO_INCREMENT de la tabla `talle`
--
ALTER TABLE `talle`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=19;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `precio`
--
ALTER TABLE `precio`
  ADD CONSTRAINT `precio_ibfk_1` FOREIGN KEY (`idProducto`) REFERENCES `productos` (`id`);

--
-- Filtros para la tabla `productos`
--
ALTER TABLE `productos`
  ADD CONSTRAINT `productos_ibfk_1` FOREIGN KEY (`categoriaId`) REFERENCES `categorias` (`id`);

--
-- Filtros para la tabla `producto_talle`
--
ALTER TABLE `producto_talle`
  ADD CONSTRAINT `producto_talle_ibfk_1` FOREIGN KEY (`idProducto`) REFERENCES `productos` (`id`),
  ADD CONSTRAINT `producto_talle_ibfk_2` FOREIGN KEY (`idTalle`) REFERENCES `talle` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
