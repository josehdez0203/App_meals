"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.default = handleDbExceptions;
const common_1 = require("@nestjs/common");
function handleDbExceptions(error, logger) {
    logger.error(error);
    if (error.code === '23505' || error.code === '23503')
        throw new common_1.BadRequestException(error.detail);
    if (error.code === '23502')
        throw new common_1.BadRequestException('Relationships between entities, invalid');
    throw new common_1.InternalServerErrorException('Unexpected error, check server logs');
}
//# sourceMappingURL=error.db.exception.js.map