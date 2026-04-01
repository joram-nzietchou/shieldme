const { body, validationResult } = require('express-validator');

const validate = (validations) => {
  return async (req, res, next) => {
    await Promise.all(validations.map(validation => validation.run(req)));
    
    const errors = validationResult(req);
    if (errors.isEmpty()) {
      return next();
    }
    
    res.status(400).json({
      success: false,
      errors: errors.array().map(err => ({
        field: err.param,
        message: err.msg,
      })),
    });
  };
};

const authValidations = {
  sendOTP: [
    body('phone')
      .notEmpty().withMessage('Le numéro de téléphone est requis')
      .isMobilePhone().withMessage('Numéro de téléphone invalide'),
  ],
  
  verifyOTP: [
    body('phone')
      .notEmpty().withMessage('Le numéro de téléphone est requis'),
    body('otp')
      .notEmpty().withMessage('Le code OTP est requis')
      .isLength({ min: 6, max: 6 }).withMessage('Le code doit contenir 6 chiffres')
      .isNumeric().withMessage('Le code doit contenir uniquement des chiffres'),
    body('fullName')
      .optional()
      .isLength({ min: 2 }).withMessage('Le nom doit contenir au moins 2 caractères'),
    body('referralCode')
      .optional()
      .matches(/^[A-Z]{3,4}-\d{4}$/).withMessage('Format de code de parrainage invalide'),
  ],
};

module.exports = { validate, authValidations };