const Joi = require('joi');

const validators = {
  phone: Joi.string()
    .pattern(/^(\+237|237)?[2368]\d{8}$/)
    .required()
    .messages({
      'string.pattern.base': 'Numéro de téléphone invalide',
      'any.required': 'Le numéro de téléphone est requis',
    }),
  
  otp: Joi.string()
    .length(6)
    .pattern(/^\d+$/)
    .required()
    .messages({
      'string.length': 'Le code doit contenir 6 chiffres',
      'string.pattern.base': 'Le code doit contenir uniquement des chiffres',
    }),
  
  fullName: Joi.string()
    .min(2)
    .max(100)
    .required()
    .messages({
      'string.min': 'Le nom doit contenir au moins 2 caractères',
      'string.max': 'Le nom est trop long',
    }),
  
  referralCode: Joi.string()
    .pattern(/^[A-Z]{3,4}-\d{4}$/)
    .optional()
    .messages({
      'string.pattern.base': 'Format de code invalide (ex: SHIELD-1234)',
    }),
};

module.exports = { validators };