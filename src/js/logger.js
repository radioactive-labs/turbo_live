export class Logger {
    static LOG_LEVELS = {
        OFF: -1,
        ERROR: 0,
        WARN: 1,
        INFO: 2,
        DEBUG: 3
    };

    constructor(level = Logger.LOG_LEVELS.OFF) {
        this.setLevel(level)
    }

    setLevel(level) {
        if (typeof level === 'string' && level in Logger.LOG_LEVELS) {
            this.level = Logger.LOG_LEVELS[level];
        } else if (typeof level === 'number' && (level === -1 || Object.values(Logger.LOG_LEVELS).includes(level))) {
            this.level = level;
        } else {
            throw new Error('Invalid log level');
        }
    }

    error(...args) {
        if (this.level >= Logger.LOG_LEVELS.ERROR) console.error('[ERROR]', ...args);
    }

    warn(...args) {
        if (this.level >= Logger.LOG_LEVELS.WARN) console.warn('[WARN]', ...args);
    }

    info(...args) {
        if (this.level >= Logger.LOG_LEVELS.INFO) console.info('[INFO]', ...args);
    }

    debug(...args) {
        if (this.level >= Logger.LOG_LEVELS.DEBUG) console.log('[DEBUG]', ...args);
    }

    log(...args) {
        if (this.level > Logger.LOG_LEVELS.OFF) this.info(...args);
    }
}

export const logger = new Logger();

// Usage examples:
// import { Logger, logger } from './logger.js';
// 
// logger.setLevel('DEBUG');
// logger.debug('This is a debug message');
// 
// logger.setLevel(-1);
// logger.error('This error will not be logged');
// 
// const customLogger = new Logger(Logger.LOG_LEVELS.OFF);
// customLogger.error('This error will not be logged either');