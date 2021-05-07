// instead of having a field, I think to keep it sane I'll have to implement
// the whole form as a React component?

import React, { useState } from 'react'
import { loadStripe } from '@stripe/stripe-js'
import {
  CardElement,
  Elements,
  useStripe,
  useElements
} from '@stripe/react-stripe-js'
import BillingAddressField from './BillingAddressField'

const CreditCardField = ({ onChange }) => {
  const stripe = useStripe()
  const elements = useElements()

  return (
    <>
      <label
        htmlFor='stripe-elements'
        className='block text-sm font-medium text-gray-700'
      >
        Credit Card
      </label>
      <div className='mt-1'>
        <CardElement
          id='stripe-elements'
          className='block w-full border-gray-300 rounded-md shadow-sm sm:text-sm focus:ring-indigo-500 focus:border-indigo-500'
          onChange={onChange}
        />
      </div>
    </>
  )
}

const UpdateCreditCardForm = ({
  action,
  method,
  authenticityToken,
  countryOptions
}) => {
  const stripe = useStripe()
  const elements = useElements()
  const [isLoading, setIsLoading] = useState(false)

  const handleCardOnChange = event => {
    // make sure we disable the input in case of error
  }

  const handleSubmit = async event => {
    const formData = new FormData(event.target)
    event.preventDefault()

    // validate stripe card

    const billingInformation = {
      name: `${formData.get('first_name')} ${formData.get('last_name')}`,
      address_line1: formData.get('address_line1'),
      address_city: formData.get('address_city'),
      address_zip: formData.get('address_zip'),
      address_state: formData.get('address_state'),
      address_country: formData.get('address_country_code')
    }

    // tokenize card and billing information
    let token
    try {
      const tokenResult = await stripe.createToken(
        elements.getElement(CardElement),
        billingInformation
      )

      token = tokenResult.token
    } catch (e) {
      console.log(e)
      return
    }

    // add stripe_token and card information to payload
    // make request
    formData.set('stripe_token', token.id)
    formData.set('stripe_card_id', token.card.id)
    formData.set('stripe_card_last4', token.card.last4)

    try {
      const response = await fetch('/membership/update_card.json', {
        method: 'POST',
        body: formData
      })
    } catch (e) {
      console.log(e)
      return
    }

    setIsLoading(false)
  }

  return (
    <form
      onSubmit={handleSubmit}
      className='space-y-8'
      action={action}
      method={method}
    >
      <input
        type='hidden'
        name='authenticity_token'
        value={authenticityToken}
      />

      <div className='grid grid-cols-1 mt-6 gap-y-4 gap-x-4 sm:grid-cols-6'>
        <div className='sm:col-span-3'>
          <label
            htmlFor='stripe-elements'
            className='block text-sm font-medium text-gray-700'
          >
            First name
          </label>
          <input
            type='text'
            name='first_name'
            className='block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm'
            required
          />
        </div>

        <div className='sm:col-span-3'>
          <label
            htmlFor='stripe-elements'
            className='block text-sm font-medium text-gray-700'
          >
            Last name
          </label>
          <input
            type='text'
            name='last_name'
            required
            className='block w-full border-gray-300 rounded-md shadow-sm focus:ring-indigo-500 focus:border-indigo-500 sm:text-sm'
          />
        </div>

        <div className='sm:col-span-6'>
          <BillingAddressField countryOptions={countryOptions} />
        </div>

        <div className='sm:col-span-6'>
          <CreditCardField onChange={handleCardOnChange} />
        </div>
      </div>

      <div className='pt-5'>
        <div className='flex justify-end'>
          <button
            disabled={isLoading}
            className='inline-flex justify-center px-4 py-2 ml-3 text-sm font-medium text-white bg-indigo-600 border border-transparent rounded-md shadow-sm hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500'
          >
            Save
          </button>
        </div>
      </div>
    </form>
  )
}

const stripePromise = loadStripe(process.env.STRIPE_PUBLISHABLE_KEY)

const FormWrapped = props => (
  <Elements stripe={stripePromise}>
    <UpdateCreditCardForm {...props} />
  </Elements>
)

export default FormWrapped
