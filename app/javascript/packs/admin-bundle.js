import ReactOnRails from 'react-on-rails'

import Drawer from '../bundles/Admin/components/Drawer'
import { UsersTable } from '../bundles/Admin/components/Users'
import { SubscriptionsTable } from '../bundles/Admin/components/Subscriptions'
import { PlansTable } from '../bundles/Admin/components/Plans'

ReactOnRails.register({
  Drawer,
  UsersTable,
  SubscriptionsTable,
  PlansTable
})
