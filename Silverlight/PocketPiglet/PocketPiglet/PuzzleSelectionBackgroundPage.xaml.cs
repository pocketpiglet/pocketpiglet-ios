using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Input;
using System.Windows.Media;
using System.Windows.Media.Animation;
using System.Windows.Shapes;
using Microsoft.Phone.Controls;
using System.Windows.Navigation;
using System.IO.IsolatedStorage;

namespace PocketPiglet
{
    public partial class PuzzleSelectionBackgroundPage : PhoneApplicationPage
    {
        private string typeLevel;
        public PuzzleSelectionBackgroundPage()
        {
            InitializeComponent();
        }

        private void ImageHeartBalloon_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            NavigationService.Navigate(new Uri("/PuzzleGamePage.xaml?typeLevel=" + Uri.EscapeDataString(typeLevel) + "&typeBackground=heart_balloon", UriKind.Relative));
        }

        private void ImagePigletOnPotty_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            NavigationService.Navigate(new Uri("/PuzzleGamePage.xaml?typeLevel=" + Uri.EscapeDataString(typeLevel) + "&typeBackground=piglet_on_potty", UriKind.Relative));
        }

        private void ImageWateringFlowers_MouseLeftButtonDown(object sender, MouseButtonEventArgs e)
        {
            NavigationService.Navigate(new Uri("/PuzzleGamePage.xaml?typeLevel=" + Uri.EscapeDataString(typeLevel) + "&typeBackground=watering_flowers", UriKind.Relative));
        }

        protected override void OnNavigatingFrom(NavigatingCancelEventArgs e)
        {
            base.OnNavigatingFrom(e);

            IsolatedStorageSettings.ApplicationSettings["AnimationPigletPlay"] = "";
            IsolatedStorageSettings.ApplicationSettings.Save();
        }

        protected override void OnNavigatedTo(NavigationEventArgs e)
        {
            base.OnNavigatedTo(e);

            if (NavigationContext.QueryString.ContainsKey("typeLevel"))
            {
                this.typeLevel = NavigationContext.QueryString["typeLevel"].ToString();
            }
        }
    }
}